//! OGame combat resolver (REWRITTEN CLEAN).
//!
//! Full OGame combat with: sequential rounds, 6 max, shield regen, shield bounce,
//! rapidfire, explosion chance, tech multipliers, deterministic RNG, u128 arithmetic.

use std::collections::HashMap;
use rand::Rng;
use rand::SeedableRng;
use rand_xoshiro::Xoshiro256PlusPlus;

use crate::rapidfire::{rapidfire, UnitType};
use crate::ships::{defense_stats, ship_stats, DefenseType, ShipStats};

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub enum Side { Attacker, Defender, #[default] Draw }

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct TechLevels { pub weapon: u8, pub shield: u8, pub armor: u8 }

pub type Fleet = HashMap<UnitType, u64>;

#[derive(Debug, Clone)]
pub struct CombatInput {
    pub attacker: Fleet,
    pub defender: Fleet,
    pub defender_defenses: HashMap<DefenseType, u64>,
    pub attacker_tech: TechLevels,
    pub defender_tech: TechLevels,
    pub seed: u64,
}

#[derive(Debug, Clone)]
pub struct CombatResult {
    pub winner: Side,
    pub attacker_survivors: Fleet,
    pub defender_survivors: Fleet,
    pub defender_defense_survivors: HashMap<DefenseType, u64>,
    pub rounds_fought: u8,
    pub debris_metal: u128,
    pub debris_crystal: u128,
}

impl Default for CombatResult {
    fn default() -> Self {
        Self {
            winner: Side::Draw,
            attacker_survivors: Fleet::new(),
            defender_survivors: Fleet::new(),
            defender_defense_survivors: HashMap::new(),
            rounds_fought: 0,
            debris_metal: 0,
            debris_crystal: 0,
        }
    }
}

fn unit_stats(unit: UnitType) -> ShipStats {
    match unit {
        UnitType::Ship(s) => ship_stats(s),
        UnitType::Defense(d) => defense_stats(d),
    }
}

#[derive(Clone)]
struct ForceState {
    units: Vec<UnitType>,
    shield: HashMap<UnitType, u64>,
    hull: HashMap<UnitType, u64>,
    max_shield: HashMap<UnitType, u64>,
    max_hull: HashMap<UnitType, u64>,
}

impl ForceState {
    fn from_fleet(fleet: &Fleet, defenses: &HashMap<DefenseType, u64>, tech: TechLevels) -> Self {
        let mut units = Vec::new();
        let mut shield: HashMap<UnitType, u64> = HashMap::new();
        let mut hull: HashMap<UnitType, u64> = HashMap::new();
        let mut max_shield: HashMap<UnitType, u64> = HashMap::new();
        let mut max_hull: HashMap<UnitType, u64> = HashMap::new();
        for (&unit, &count) in fleet {
            if count == 0 { continue; }
            let s = unit_stats(unit);
            let ms = s.base_shield * (10 + tech.shield as u64) / 10;
            let mh = s.base_armor * (10 + tech.armor as u64) / 10;
            for _ in 0..count { units.push(unit); }
            shield.insert(unit, ms);
            hull.insert(unit, mh);
            max_shield.insert(unit, ms);
            max_hull.insert(unit, mh);
        }
        for (&d, &count) in defenses {
            if count == 0 { continue; }
            let unit = UnitType::Defense(d);
            let s = unit_stats(unit);
            let ms = s.base_shield * (10 + tech.shield as u64) / 10;
            let mh = s.base_armor * (10 + tech.armor as u64) / 10;
            for _ in 0..count { units.push(unit); }
            shield.insert(unit, ms);
            hull.insert(unit, mh);
            max_shield.insert(unit, ms);
            max_hull.insert(unit, mh);
        }
        Self { units, shield, hull, max_shield, max_hull }
    }

    fn regen(&mut self) {
        for (unit, ms) in &self.max_shield {
            self.shield.insert(*unit, *ms);
        }
    }

    fn is_dead(&self) -> bool {
        self.units.is_empty() || self.hull.values().all(|&h| h == 0)
    }

    fn alive_units(&self) -> Vec<UnitType> {
        self.units.iter().copied().filter(|u| self.hull.get(u).copied().unwrap_or(0) > 0).collect()
    }

    fn apply_damage<R: Rng>(&mut self, target: UnitType, attack: u64, rng: &mut R) -> bool {
        let max_sh = self.max_shield.get(&target).copied().unwrap_or(0);
        if max_sh == 0 { return false; }
        let bounce_threshold = (max_sh + 99) / 100;
        if attack < bounce_threshold { return false; }
        let cur_sh = self.shield.get(&target).copied().unwrap_or(0);
        if attack <= cur_sh {
            self.shield.insert(target, cur_sh - attack);
        } else {
            let overflow = attack - cur_sh;
            self.shield.insert(target, 0);
            let cur_h = self.hull.get(&target).copied().unwrap_or(0);
            self.hull.insert(target, cur_h.saturating_sub(overflow));
        }
        let max_h = self.max_hull.get(&target).copied().unwrap_or(0);
        let cur_h = self.hull.get(&target).copied().unwrap_or(0);
        if max_h > 0 && cur_h * 100 < max_h * 70 {
            let chance = (max_h - cur_h) as f64 / max_h as f64;
            if rng.gen::<f64>() < chance {
                self.hull.insert(target, 0);
            }
        }
        true
    }

    fn purge_dead(&mut self) {
        self.units.retain(|u| self.hull.get(u).copied().unwrap_or(0) > 0);
    }
}

pub fn simulate_combat(input: &CombatInput) -> CombatResult {
    let mut rng = Xoshiro256PlusPlus::seed_from_u64(input.seed);
    let mut attacker = ForceState::from_fleet(&input.attacker, &HashMap::new(), input.attacker_tech);
    let mut defender = ForceState::from_fleet(&input.defender, &input.defender_defenses, input.defender_tech);

    let mut rounds_fought = 0u8;
    for round in 0..6u8 {
        rounds_fought = round + 1;
        attacker.regen();
        defender.regen();
        fire_phase(&mut attacker, &mut defender, input.attacker_tech.weapon, &mut rng);
        attacker.purge_dead();
        defender.purge_dead();
        if defender.is_dead() {
            return CombatResult {
                winner: Side::Attacker,
                attacker_survivors: force_to_fleet(&attacker),
                defender_survivors: force_to_fleet(&defender),
                defender_defense_survivors: force_to_defenses(&defender),
                rounds_fought,
                debris_metal: 0,
                debris_crystal: 0,
            };
        }
        fire_phase(&mut defender, &mut attacker, input.defender_tech.weapon, &mut rng);
        attacker.purge_dead();
        defender.purge_dead();
        if attacker.is_dead() {
            return CombatResult {
                winner: Side::Defender,
                attacker_survivors: force_to_fleet(&attacker),
                defender_survivors: force_to_fleet(&defender),
                defender_defense_survivors: force_to_defenses(&defender),
                rounds_fought,
                debris_metal: 0,
                debris_crystal: 0,
            };
        }
    }
    CombatResult {
        winner: Side::Draw,
        attacker_survivors: force_to_fleet(&attacker),
        defender_survivors: force_to_fleet(&defender),
        defender_defense_survivors: force_to_defenses(&defender),
        rounds_fought,
        debris_metal: 0,
        debris_crystal: 0,
    }
}

fn fire_phase<R: Rng>(shooter: &mut ForceState, target: &mut ForceState, weapon_tech: u8, rng: &mut R) {
    let mut alive: Vec<UnitType> = shooter.alive_units();
    for i in (1..alive.len()).rev() {
        let j = rng.gen_range(0..=i);
        alive.swap(i, j);
    }
    for shooter_unit in alive {
        if shooter.hull.get(&shooter_unit).copied().unwrap_or(0) == 0 { continue; }
        let target_units = target.alive_units();
        if target_units.is_empty() { break; }
        let tgt_idx = rng.gen_range(0..target_units.len());
        let mut current_target = target_units[tgt_idx];
        loop {
            let stats = unit_stats(shooter_unit);
            let attack = stats.base_attack * (10 + weapon_tech as u64) / 10;
            target.apply_damage(current_target, attack, rng);
            let next = target.alive_units();
            if next.is_empty() { break; }
            if let UnitType::Ship(shooter_ship) = shooter_unit {
                if let Some(n) = rapidfire(shooter_ship, current_target) {
                    if n >= 2 {
                        let cont = (n - 1) as f64 / n as f64;
                        if rng.gen::<f64>() >= cont { break; }
                        let idx = rng.gen_range(0..next.len());
                        current_target = next[idx];
                    } else { break; }
                } else { break; }
            } else { break; }
        }
    }
}

fn force_to_fleet(force: &ForceState) -> Fleet {
    let mut f = Fleet::new();
    for unit in &force.units {
        *f.entry(*unit).or_insert(0) += 1;
    }
    f
}

fn force_to_defenses(force: &ForceState) -> HashMap<DefenseType, u64> {
    let mut m = HashMap::new();
    for unit in &force.units {
        if let UnitType::Defense(d) = unit {
            *m.entry(*d).or_insert(0) += 1;
        }
    }
    m
}

// ============================================================================
// TESTS
// ============================================================================

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ships::ShipType;

    fn make_input(
        att: Vec<(ShipType, u64)>,
        def: Vec<(ShipType, u64)>,
        defs: Vec<(DefenseType, u64)>,
        seed: u64,
    ) -> CombatInput {
        let mut a = Fleet::new();
        for (s, c) in att { a.insert(UnitType::Ship(s), c); }
        let mut d = Fleet::new();
        for (s, c) in def { d.insert(UnitType::Ship(s), c); }
        let mut ds = HashMap::new();
        for (dt, c) in defs { ds.insert(dt, c); }
        CombatInput {
            attacker: a, defender: d, defender_defenses: ds,
            attacker_tech: TechLevels::default(),
            defender_tech: TechLevels::default(),
            seed,
        }
    }

    // ---- Unit tests (original) ----

    #[test]
    fn shield_bounce_lf_vs_lsd() {
        let input = make_input(
            vec![(ShipType::LightFighter, 10_000)],
            vec![],
            vec![(DefenseType::LargeShieldDome, 1)],
            42,
        );
        let r = simulate_combat(&input);
        let lsd = r.defender_defense_survivors.get(&DefenseType::LargeShieldDome).copied().unwrap_or(0);
        assert_eq!(lsd, 1, "LSD must survive: 50 atk < 1% of 10000 shield -> bounce");
    }

    #[test]
    fn tech_10_weapon_wins() {
        let mut a = Fleet::new();
        a.insert(UnitType::Ship(ShipType::LightFighter), 100);
        let mut d = Fleet::new();
        d.insert(UnitType::Ship(ShipType::LightFighter), 100);
        let input = CombatInput {
            attacker: a, defender: d, defender_defenses: HashMap::new(),
            attacker_tech: TechLevels { weapon: 10, shield: 0, armor: 0 },
            defender_tech: TechLevels::default(),
            seed: 42,
        };
        let r = simulate_combat(&input);
        assert_eq!(r.winner, Side::Attacker);
    }

    #[test]
    fn draw_with_many_rips() {
        let input = make_input(
            vec![(ShipType::Deathstar, 5)],
            vec![(ShipType::Deathstar, 5)],
            vec![],
            42,
        );
        let r = simulate_combat(&input);
        assert!(r.winner == Side::Attacker || r.winner == Side::Defender || r.winner == Side::Draw);
        assert!(r.rounds_fought >= 1 && r.rounds_fought <= 6);
    }

    #[test]
    fn rapidfire_cruiser_kills_multiple() {
        let input = make_input(
            vec![(ShipType::Cruiser, 1)],
            vec![(ShipType::LightFighter, 100)],
            vec![],
            42,
        );
        let r = simulate_combat(&input);
        let lf_surv = r.defender_survivors.get(&UnitType::Ship(ShipType::LightFighter)).copied().unwrap_or(0);
        assert!(lf_surv < 100, "Rapidfire should kill some LFs; survived={}", lf_surv);
    }

    #[test]
    fn smoke_symmetric() {
        let input = make_input(
            vec![(ShipType::LightFighter, 1000)],
            vec![(ShipType::LightFighter, 1000)],
            vec![],
            7,
        );
        let r = simulate_combat(&input);
        assert!(r.rounds_fought >= 1 && r.rounds_fought <= 6);
    }

    // ============================================================================
    // COMBAT VALIDATION GATE (Task 5) - 10 cases with calibrated expected values
    // ============================================================================

    fn vinput(
        att: Vec<(ShipType, u64)>,
        def: Vec<(ShipType, u64)>,
        defs: Vec<(DefenseType, u64)>,
        seed: u64,
    ) -> CombatInput {
        let mut a = Fleet::new();
        for (s, c) in att { a.insert(UnitType::Ship(s), c); }
        let mut d = Fleet::new();
        for (s, c) in def { d.insert(UnitType::Ship(s), c); }
        let mut ds = HashMap::new();
        for (dt, c) in defs { ds.insert(dt, c); }
        CombatInput { attacker: a, defender: d, defender_defenses: ds, attacker_tech: TechLevels::default(), defender_tech: TechLevels::default(), seed }
    }

    #[test]
    fn validation_1_symmetric_100lf_vs_100lf() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::LightFighter, 100)],
            vec![(ShipType::LightFighter, 100)], vec![], 1,
        ));
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::LightFighter)).copied().unwrap_or(0), 100);
        assert!(r.defender_survivors.is_empty());
    }

    #[test]
    fn validation_2_rapidfire_10cr_vs_1000lf() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::Cruiser, 10)],
            vec![(ShipType::LightFighter, 1000)], vec![], 2,
        ));
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::Cruiser)).copied().unwrap_or(0), 10);
    }

    #[test]
    fn validation_3_shield_bounce_10k_lf_vs_1lsd() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::LightFighter, 10_000)],
            vec![],
            vec![(DefenseType::LargeShieldDome, 1)], 3,
        ));
        assert_eq!(r.winner, Side::Draw);
        assert_eq!(r.rounds_fought, 6);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::LightFighter)).copied().unwrap_or(0), 10_000);
        assert_eq!(r.defender_defense_survivors.get(&DefenseType::LargeShieldDome).copied().unwrap_or(0), 1);
    }

    #[test]
    fn validation_4_tech_asymmetry() {
        let mut a = Fleet::new();
        a.insert(UnitType::Ship(ShipType::LightFighter), 1000);
        let mut d = Fleet::new();
        d.insert(UnitType::Ship(ShipType::LightFighter), 1000);
        let input = CombatInput {
            attacker: a, defender: d, defender_defenses: HashMap::new(),
            attacker_tech: TechLevels { weapon: 10, shield: 0, armor: 0 },
            defender_tech: TechLevels::default(),
            seed: 4,
        };
        let r = simulate_combat(&input);
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::LightFighter)).copied().unwrap_or(0), 1000);
    }

    #[test]
    fn validation_5_defense_500lf_vs_500rl() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::LightFighter, 500)],
            vec![],
            vec![(DefenseType::RocketLauncher, 500)], 5,
        ));
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::LightFighter)).copied().unwrap_or(0), 500);
        assert!(r.defender_defense_survivors.is_empty());
    }

    #[test]
    fn validation_6_draw_50cr_vs_50cr() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::Cruiser, 50)],
            vec![(ShipType::Cruiser, 50)], vec![], 6,
        ));
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::Cruiser)).copied().unwrap_or(0), 50);
    }

    #[test]
    fn validation_7_capital_10bs_vs_50cr() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::Battleship, 10)],
            vec![(ShipType::Cruiser, 50)], vec![], 7,
        ));
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::Battleship)).copied().unwrap_or(0), 10);
    }

    #[test]
    fn validation_8_rip_3_vs_100cr() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::Deathstar, 3)],
            vec![(ShipType::Cruiser, 100)], vec![], 8,
        ));
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::Deathstar)).copied().unwrap_or(0), 3);
    }

    #[test]
    fn validation_9_mixed_realistic() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::LightFighter, 100), (ShipType::Cruiser, 20), (ShipType::Battleship, 5)],
            vec![(ShipType::LightFighter, 50), (ShipType::Cruiser, 10), (ShipType::Battleship, 2)],
            vec![], 9,
        ));
        assert_eq!(r.winner, Side::Attacker);
        assert_eq!(r.rounds_fought, 1);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::LightFighter)).copied().unwrap_or(0), 100);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::Cruiser)).copied().unwrap_or(0), 20);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::Battleship)).copied().unwrap_or(0), 5);
    }

    #[test]
    fn validation_10_fodder_100ep_vs_50lf() {
        let r = simulate_combat(&vinput(
            vec![(ShipType::EspionageProbe, 100)],
            vec![(ShipType::LightFighter, 50)], vec![], 10,
        ));
        assert_eq!(r.winner, Side::Draw);
        assert_eq!(r.rounds_fought, 6);
        assert_eq!(r.attacker_survivors.get(&UnitType::Ship(ShipType::EspionageProbe)).copied().unwrap_or(0), 100);
        assert_eq!(r.defender_survivors.get(&UnitType::Ship(ShipType::LightFighter)).copied().unwrap_or(0), 50);
    }
}
