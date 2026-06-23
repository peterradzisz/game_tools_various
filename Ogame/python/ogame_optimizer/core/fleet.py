"""OGame fleet, defense, and budget primitives.

This module is the Python-side authoritative source for the optimizer's
budget math.  The Rust combat simulator (``src/ships.rs``) carries its own
copy of the unit costs for parity checks; if the two drift apart, the
``test_ships_cost_matches_rust_source_of_truth`` test in
``python_tests/test_fleet.py`` will fail immediately.

Keys
----
Public ship and defense keys are lowercase snake_case (``"light_fighter"``,
``"rocket_launcher"``, ``"deathstar"``).  The Rust core uses PascalCase
identifiers (``"LightFighter"``); conversion happens at the PyO3 bridge
(Task 6) — never silently inside this module.
"""
from __future__ import annotations

import math
from dataclasses import dataclass, field
from typing import Dict, Mapping, Optional


# ---------------------------------------------------------------------------
# Cost tables — verified against src/ships.rs.
# ---------------------------------------------------------------------------

# Each value is ``(metal, crystal, deuterium)`` raw resources per unit, with
# no build multiplier applied.  Order matches ``ShipType::ALL`` in ships.rs.
SHIPS_COST: Dict[str, tuple] = {
    "small_cargo":      (2_000,        2_000,      0),
    "large_cargo":      (6_000,        6_000,      0),
    "light_fighter":    (3_000,        1_000,      0),
    "heavy_fighter":    (6_000,        4_000,      0),
    "cruiser":          (20_000,       7_000,      2_000),
    "battleship":       (45_000,       15_000,     0),
    "battlecruiser":    (30_000,       40_000,     15_000),
    "bomber":           (50_000,       25_000,     15_000),
    "destroyer":        (60_000,       50_000,     15_000),
    "deathstar":        (5_000_000,    4_000_000,  1_000_000),
    "pathfinder": (10000, 10000, 2000),
    "recycler": (10000, 6000, 2000),
    "espionage_probe":  (0,            1_000,      0),
}

# Order matches ``DefenseType::ALL`` in ships.rs.
DEFENSES_COST: Dict[str, tuple] = {
    "rocket_launcher":     (2_000,    0,          0),
    "light_laser":         (1_500,    500,        0),
    "heavy_laser":         (6_000,    2_000,      0),
    "gauss_cannon":        (20_000,   15_000,     2_000),
    "ion_cannon":          (5_000,    3_000,      0),
    "plasma_turret":       (50_000,   50_000,     30_000),
    "small_shield_dome":   (10_000,   10_000,     0),
    "large_shield_dome":   (50_000,   50_000,     0),
}

# Tolerance for "is this multiplier on the 0.5 grid?" — accommodates IEEE 754
# rounding noise from values like ``0.1 + 0.1 + 0.1 + 0.1 + 0.1``.
_GRID_TOLERANCE: float = 1e-9


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _unit_cost(unit_key: str, table: Mapping[str, tuple]) -> int:
    """Return the per-unit M+C+D total for ``unit_key`` from ``table``."""
    try:
        metal, crystal, deuterium = table[unit_key]
    except KeyError as exc:
        raise ValueError(
            f"Unknown unit key {unit_key!r}; expected one of {sorted(table)!r}"
        ) from exc
    return metal + crystal + deuterium


def _validate_counts(
    counts: Mapping[str, int],
    table: Mapping[str, tuple],
    label: str,
) -> None:
    """Raise ``ValueError`` on unknown keys or non-int / negative counts."""
    for key, count in counts.items():
        if key not in table:
            raise ValueError(
                f"Unknown {label} key {key!r}; expected one of {sorted(table)!r}"
            )
        # ``bool`` is a subclass of ``int`` in Python; reject it explicitly so
        # ``Fleet(ships={'light_fighter': True})`` is a clear error rather
        # than a silently-misleading ``1``.
        if isinstance(count, bool) or not isinstance(count, int):
            raise ValueError(
                f"{label} count for {key!r} must be an int, got {type(count).__name__}"
            )
        if count < 0:
            raise ValueError(
                f"{label} count for {key!r} must be non-negative, got {count}"
            )


# ---------------------------------------------------------------------------
# Public dataclass
# ---------------------------------------------------------------------------


@dataclass
class Fleet:
    """A combat fleet composition: ``Dict[ship_key, count]``.

    ``ship_key`` must be one of the keys in :data:`SHIPS_COST`.  Counts are
    non-negative Python ``int`` (no floats, no bools).
    """

    ships: Dict[str, int] = field(default_factory=dict)

    def __post_init__(self) -> None:
        _validate_counts(self.ships, SHIPS_COST, label="ship")

    def total_cost(self) -> int:
        """Return raw M+C+D total cost of this fleet."""
        return sum(
            count * _unit_cost(key, SHIPS_COST)
            for key, count in self.ships.items()
        )


# ---------------------------------------------------------------------------
# Free-function API (used by optimizer heuristics that work on plain dicts)
# ---------------------------------------------------------------------------


def fleet_value(
    fleet: Mapping[str, int],
    defenses: Optional[Mapping[str, int]] = None,
) -> int:
    """Return raw M+C+D value of ``fleet`` plus ``defenses`` (both optional).

    Used to compute "what does this enemy cost to replace?" for the budget
    ceiling.  ``defenses`` is ``None`` when the player is scouting a fleet
    with no stationary defenses (common in ACS / expedition scenarios).
    """
    _validate_counts(fleet, SHIPS_COST, label="ship")
    total = sum(
        count * _unit_cost(key, SHIPS_COST) for key, count in fleet.items()
    )
    if defenses is not None:
        _validate_counts(defenses, DEFENSES_COST, label="defense")
        total += sum(
            count * _unit_cost(key, DEFENSES_COST)
            for key, count in defenses.items()
        )
    return total


def validate_multiplier(multiplier: float) -> None:
    """Validate that ``multiplier`` is positive and on the 0.1-step grid.

    Allowed values: ``0.1, 0.2, ..., 1.0, 1.5, 2.0, ...``.  Off-grid values
    like ``0.37, 0.55, 1.25`` are rejected because they would produce a
    non-integer-currency budget (e.g. 300,000.00000000003 metal).

    Float-precision tolerance accommodates arithmetic like
    ``0.1 + 0.1 + 0.1 + 0.1 + 0.1`` that the user might intend as 0.5.
    """
    if not isinstance(multiplier, (int, float)) or isinstance(multiplier, bool):
        raise ValueError(
            f"multiplier must be a number, got {type(multiplier).__name__}"
        )
    if multiplier <= 0:
        raise ValueError(
            f"multiplier must be positive, got {multiplier}"
        )
    tenth = float(multiplier) * 10.0
    if not math.isclose(tenth, round(tenth), abs_tol=_GRID_TOLERANCE):
        raise ValueError(
            f"multiplier {multiplier} is not on the 0.1-step grid "
            f"(allowed: 0.1, 0.2, ..., 1.0, 1.5, ...)"
        )


def compute_budget(
    enemy_fleet: Mapping[str, int],
    enemy_defenses: Optional[Mapping[str, int]] = None,
    multiplier: float = 1.0,
) -> int:
    """Return the budget ceiling for the counter-fleet.

    Mathematically: ``fleet_value(enemy_fleet, enemy_defenses) * multiplier``.

    The result is always an ``int`` (truncated if the float arithmetic
    produces fractional dust).  Validation of ``multiplier`` is delegated to
    :func:`validate_multiplier` so the failure mode is identical regardless
    of whether the caller goes through this entry point or pre-validates.
    """
    validate_multiplier(multiplier)
    raw = fleet_value(enemy_fleet, enemy_defenses)
    return int(raw * multiplier)


def validate_fleet_in_budget(
    fleet: Mapping[str, int],
    budget: int,
) -> bool:
    """Return ``True`` iff ``fleet``'s total cost is ``<= budget``."""
    _validate_counts(fleet, SHIPS_COST, label="ship")
    if not isinstance(budget, int) or isinstance(budget, bool):
        raise ValueError(
            f"budget must be an int, got {type(budget).__name__}"
        )
    if budget < 0:
        raise ValueError(f"budget must be non-negative, got {budget}")
    return sum(
        count * _unit_cost(key, SHIPS_COST) for key, count in fleet.items()
    ) <= budget


__all__ = [
    "DEFENSES_COST",
    "SHIPS_COST",
    "Fleet",
    "compute_budget",
    "fleet_value",
    "validate_fleet_in_budget",
    "validate_multiplier",
]
# Base attack values for each ship (from src/ships.rs base_attack)
SHIP_BASE_ATK: Dict[str, int] = {
    "small_cargo": 5, "large_cargo": 5,
    "light_fighter": 50, "heavy_fighter": 150,
    "cruiser": 400, "battleship": 1000, "battlecruiser": 700,
    "bomber": 1000, "destroyer": 2000, "deathstar": 200000,
    "pathfinder": (10000, 10000, 2000),
    "recycler": (10000, 6000, 2000),
    "pathfinder": 300,
    "recycler": 1,
    "espionage_probe": 0,
}
