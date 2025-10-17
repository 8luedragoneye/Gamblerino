# Dynamic Pattern System Design

## Overview
A completely flexible pattern generation system that automatically discovers and values patterns based on any grid size, controlled by charms and phone calls.

## Core Concepts

### 1. Flexible Grid Sizing
- **Any dimensions**: 3x3, 4x4, 3x9, 7x2, 1x10, 6x6, etc.
- **Individual control**: Add rows and columns separately
- **Charm/Phone Call driven**: Grid size changes through game mechanics, not levels

### 2. Dynamic Pattern Discovery
- **Simple pattern extension**: Existing patterns extend when grid grows
- **Size-adaptive**: Patterns automatically adjust to grid dimensions
- **Minimal pattern list**: Only store base patterns, extend on demand

### 3. Automatic Pattern Valuation
- **Length-based**: Longer patterns = more valuable
- **Rarity-based**: Harder to achieve = more valuable
- **Complexity-based**: Complex shapes = more valuable
- **Grid-adaptive**: Values adjust based on grid size and difficulty

## System Architecture

### Grid Size Control

#### Charm Effects
```typescript
interface GridSizeModifier {
  type: 'charm' | 'phone_call' | 'temporary';
  source: string;
  rows: number;
  cols: number;
  duration?: number; // for temporary effects
}

// Example charm effects
const gridSizeCharms = {
  'expansive-vision': { rows: +1, cols: +1, permanent: true },
  'temporary-expansion': { rows: +2, cols: +2, duration: 3 }, // 3 spins
  'mini-grid': { rows: -1, cols: -1, permanent: true }, // risk/reward
  'wide-screen': { rows: 0, cols: +3, permanent: true },
  'tall-tower': { rows: +3, cols: 0, permanent: true }
};
```

#### Phone Call Effects
```typescript
const patternPhoneCallEffects = {
  'grid-expansion': {
    description: "The caller offers to expand your grid temporarily",
    effect: { gridSize: { rows: +2, cols: +2 }, duration: 5 }
  },
  'wide-gambit': {
    description: "Make your grid extremely wide",
    effect: { gridSize: { rows: 0, cols: +5 }, duration: 3 }
  },
  'tall-challenge': {
    description: "Make your grid extremely tall",
    effect: { gridSize: { rows: +5, cols: 0 }, duration: 3 }
  }
};
```

### Simple Pattern Extension System

#### Core Pattern Types
```typescript
interface BasePattern {
  name: string;
  type: 'horizontal' | 'vertical' | 'diagonal' | 'anti-diagonal' | 'L-shape' | 'T-shape';
  minLength: number;
  maxLength: number;
  baseMultiplier: number;
}

interface Pattern {
  name: string;
  positions: number[][];
  multiplier: number;
  length: number;
  type: string;
}

// Base patterns that extend automatically
const basePatterns: BasePattern[] = [
  { name: 'horizontal', type: 'horizontal', minLength: 3, maxLength: Infinity, baseMultiplier: 1.0 },
  { name: 'vertical', type: 'vertical', minLength: 3, maxLength: Infinity, baseMultiplier: 1.0 },
  { name: 'diagonal', type: 'diagonal', minLength: 3, maxLength: Infinity, baseMultiplier: 1.2 },
  { name: 'anti-diagonal', type: 'anti-diagonal', minLength: 3, maxLength: Infinity, baseMultiplier: 1.2 },
  { name: 'L-shape', type: 'L-shape', minLength: 3, maxLength: 3, baseMultiplier: 1.5 },
  { name: 'T-shape', type: 'T-shape', minLength: 5, maxLength: 5, baseMultiplier: 1.5 }
];
```

#### Pattern Extension Logic
```typescript
class SimplePatternSystem {
  private currentGridSize = { rows: 3, cols: 3 };
  private activePatterns: Pattern[] = [];
  
  // When grid expands, extend existing patterns
  expandGrid(direction: 'row' | 'col', amount: number = 1) {
    if (direction === 'row') {
      this.currentGridSize.rows += amount;
    } else {
      this.currentGridSize.cols += amount;
    }
    
    // Extend existing patterns instead of regenerating
    this.extendExistingPatterns();
  }
  
  private extendExistingPatterns() {
    // For each existing pattern, check if it can be extended
    this.activePatterns = this.activePatterns.map(pattern => {
      if (this.canExtendPattern(pattern)) {
        return this.extendPattern(pattern);
      }
      return pattern;
    });
    
    // Add new patterns that are now possible
    this.addNewPossiblePatterns();
  }
  
  private canExtendPattern(pattern: Pattern): boolean {
    // Check if pattern can be extended by 1 in any direction
    return this.getMaxExtensionLength(pattern) > pattern.length;
  }
  
  private extendPattern(pattern: Pattern): Pattern {
    const newLength = pattern.length + 1;
    
    return {
      ...pattern,
      length: newLength,
      multiplier: this.calculateMultiplier(newLength, pattern.type)
      // No positions stored - we check all positions dynamically
    };
  }
}
```

#### Efficient Pattern Matching Logic
```typescript
class PatternMatcher {
  // Check if current grid has any matching patterns
  findMatches(grid: Symbol[][], patterns: Pattern[]): Pattern[] {
    const matches: Pattern[] = [];
    
    for (const pattern of patterns) {
      if (this.checkPatternMatch(grid, pattern)) {
        matches.push(pattern);
      }
    }
    
    return matches;
  }
  
  private checkPatternMatch(grid: Symbol[][], pattern: Pattern): boolean {
    // Check if pattern exists in grid at any position
    for (let row = 0; row < grid.length; row++) {
      for (let col = 0; col < grid[row].length; col++) {
        if (this.checkPatternAtPosition(grid, pattern, row, col)) {
          return true;
        }
      }
    }
    return false;
  }
  
  private checkPatternAtPosition(
    grid: Symbol[][], 
    pattern: Pattern, 
    startRow: number, 
    startCol: number
  ): boolean {
    // Generate positions dynamically based on pattern type and length
    const positions = this.generatePatternPositions(pattern, startRow, startCol);
    
    // Check if all positions are valid and symbols match
    for (const [row, col] of positions) {
      if (row >= grid.length || col >= grid[row].length) {
        return false; // Pattern goes out of bounds
      }
      
      // Check if symbols match (simplified - you'd check actual symbol matching)
      if (!this.symbolsMatch(grid[startRow][startCol], grid[row][col])) {
        return false;
      }
    }
    return true;
  }
  
  private generatePatternPositions(pattern: Pattern, startRow: number, startCol: number): number[][] {
    const positions: number[][] = [];
    
    switch (pattern.type) {
      case 'horizontal':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow, startCol + i]);
        }
        break;
      case 'vertical':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow + i, startCol]);
        }
        break;
      case 'diagonal':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow + i, startCol + i]);
        }
        break;
      case 'anti-diagonal':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow + i, startCol - i]);
        }
        break;
      // Add L-shape, T-shape, etc. as needed
    }
    
    return positions;
  }
}
```

#### Simple Example: Pattern Extension
```typescript
// Example: 3x3 grid with horizontal pattern "xxx"
const initialPattern = {
  name: 'horizontal-3',
  type: 'horizontal',
  length: 3,
  multiplier: 1.0
  // No positions stored - generated dynamically when checking
};

// When grid expands to 3x4, pattern extends to "xxxx"
const extendedPattern = {
  name: 'horizontal-4',
  type: 'horizontal',
  length: 4,
  multiplier: 1.2 // Higher multiplier for longer pattern
  // Still no positions - generated dynamically
};

// When grid expands to 3x5, pattern extends to "xxxxx"
const furtherExtendedPattern = {
  name: 'horizontal-5',
  type: 'horizontal',
  length: 5,
  multiplier: 1.44 // Even higher multiplier
  // Still no positions - generated dynamically
};

// Pattern matching generates positions on-the-fly:
// For horizontal-4 at position (0,0): [[0,0], [0,1], [0,2], [0,3]]
// For horizontal-4 at position (0,1): [[0,1], [0,2], [0,3], [0,4]]
// etc.
```

### Simple Valuation System

#### Multiplier Calculation
```typescript
const calculateMultiplier = (length: number, type: string) => {
  const baseMultipliers = {
    'horizontal': 1.0,
    'vertical': 1.0,
    'diagonal': 1.2,
    'anti-diagonal': 1.2,
    'L-shape': 1.5,
    'T-shape': 1.5
  };
  
  const typeBonus = baseMultipliers[type] || 1.0;
  const lengthBonus = Math.pow(1.2, length - 3); // 20% bonus per extra symbol
  
  return typeBonus * lengthBonus;
};
```

### Simple Pattern Management

#### Pattern List
```typescript
class SimplePatternManager {
  private patterns: Pattern[] = [];
  private maxPatterns = 20; // Keep it simple - max 20 patterns
  
  addPattern(pattern: Pattern) {
    if (this.patterns.length < this.maxPatterns) {
      this.patterns.push(pattern);
    }
  }
  
  getActivePatterns(): Pattern[] {
    return this.patterns;
  }
  
  // When grid expands, extend existing patterns
  onGridExpand(direction: 'row' | 'col') {
    this.patterns = this.patterns.map(pattern => {
      if (this.canExtend(pattern)) {
        return this.extendPattern(pattern);
      }
      return pattern;
    });
  }
  
  private canExtend(pattern: Pattern): boolean {
    // Simple check: can this pattern be extended?
    return pattern.type !== 'L-shape' && pattern.type !== 'T-shape';
  }
  
  private extendPattern(pattern: Pattern): Pattern {
    const newLength = pattern.length + 1;
    return {
      ...pattern,
      length: newLength,
      multiplier: this.calculateMultiplier(newLength, pattern.type),
      positions: this.generateExtendedPositions(pattern, newLength)
    };
  }
}
```

### Simple Charm Integration

#### Grid Expansion Charms
```typescript
const simpleCharms = {
  'wide-vision': {
    effect: 'expand_cols',
    amount: 1,
    description: 'Add 1 column to grid'
  },
  'tall-ambition': {
    effect: 'expand_rows', 
    amount: 1,
    description: 'Add 1 row to grid'
  },
  'big-expansion': {
    effect: 'expand_both',
    amount: 1,
    description: 'Add 1 row and 1 column'
  }
};

// When charm is activated
function activateCharm(charmId: string) {
  const charm = simpleCharms[charmId];
  
  switch (charm.effect) {
    case 'expand_cols':
      patternManager.onGridExpand('col', charm.amount);
      break;
    case 'expand_rows':
      patternManager.onGridExpand('row', charm.amount);
      break;
    case 'expand_both':
      patternManager.onGridExpand('col', charm.amount);
      patternManager.onGridExpand('row', charm.amount);
      break;
  }
}
```

### Simple Pattern Updates

#### Grid Expansion Handler
```typescript
class SimplePatternUpdater {
  private patternManager: SimplePatternManager;
  private patternMatcher: PatternMatcher;
  
  onGridExpand(direction: 'row' | 'col', amount: number) {
    // 1. Extend existing patterns
    this.patternManager.onGridExpand(direction);
    
    // 2. Check for new matches in current grid
    const activePatterns = this.patternManager.getActivePatterns();
    const matches = this.patternMatcher.findMatches(currentGrid, activePatterns);
    
    // 3. Update game state
    this.updateGameState(matches);
  }
  
  private updateGameState(matches: Pattern[]) {
    // Award coins based on matched patterns
    let totalCoins = 0;
    for (const match of matches) {
      totalCoins += this.calculateCoins(match);
    }
    
    // Update UI
    this.showMatches(matches);
    this.addCoins(totalCoins);
  }
}
```

## Simple Example Scenarios

### Scenario 1: Grid Expansion
**Starting Grid (3x3):**
```
🍋 🍒 🍀
🔔 💎 💰
7️⃣ 🍋 🍒
```

**Active Patterns:**
- 3-symbol horizontal: 5 coins
- 3-symbol vertical: 5 coins  
- 3-symbol diagonal: 6 coins

**After "Wide Vision" Charm (3x4):**
```
🍋 🍒 🍀 🔔
🔔 💎 💰 7️⃣
7️⃣ 🍋 🍒 🍀
```

**Extended Patterns:**
- 4-symbol horizontal: 6 coins (extended from 3-symbol)
- 3-symbol vertical: 5 coins (unchanged)
- 3-symbol diagonal: 6 coins (unchanged)

### Scenario 2: Pattern Matching
**Current Grid:**
```
🍋 🍋 🍋
🔔 💎 💰
7️⃣ 🍋 🍒
```

**Pattern Matches:**
- ✅ 3-symbol horizontal (🍋🍋🍋): 5 coins
- ❌ 3-symbol vertical: No match
- ❌ 3-symbol diagonal: No match

**Total Coins Awarded: 5**

## Benefits of Simple System

### 1. **Super Simple Logic**
- Start with basic patterns (horizontal, vertical, diagonal)
- When grid expands, extend existing patterns
- Check grid for matches against pattern list

### 2. **No Performance Issues**
- Max 20 patterns at any time
- No complex generation algorithms
- Fast pattern matching

### 3. **Easy to Understand**
- Clear cause and effect: expand grid → extend patterns
- Simple pattern matching: check if symbols match
- Straightforward coin calculation

### 4. **Easy to Implement**
- No complex caching needed
- No background workers
- No memory management issues

### 5. **Player Friendly**
- Clear feedback: "You got 4-symbol horizontal for 6 coins!"
- Predictable: players know what patterns to expect
- Strategic: choose when to expand grid for better patterns

## Simple Implementation

### Core System (No Performance Issues!)
```typescript
class SimplePatternSystem {
  private patterns: Pattern[] = [];
  private maxPatterns = 20;
  
  // Start with basic patterns
  initialize() {
    this.patterns = [
      { name: 'horizontal-3', type: 'horizontal', length: 3, multiplier: 1.0 },
      { name: 'vertical-3', type: 'vertical', length: 3, multiplier: 1.0 },
      { name: 'diagonal-3', type: 'diagonal', length: 3, multiplier: 1.2 }
    ];
  }
  
  // When grid expands, extend patterns
  onGridExpand(direction: 'row' | 'col') {
    this.patterns = this.patterns.map(pattern => {
      if (this.canExtend(pattern)) {
        return this.extendPattern(pattern);
      }
      return pattern;
    });
  }
  
  // Check current grid for matches
  findMatches(grid: Symbol[][]): Pattern[] {
    const matches: Pattern[] = [];
    for (const pattern of this.patterns) {
      if (this.checkMatch(grid, pattern)) {
        matches.push(pattern);
      }
    }
    return matches;
  }
  
  private checkMatch(grid: Symbol[][], pattern: Pattern): boolean {
    // Check pattern at every possible position in grid
    for (let row = 0; row < grid.length; row++) {
      for (let col = 0; col < grid[row].length; col++) {
        if (this.checkPatternAtPosition(grid, pattern, row, col)) {
          return true;
        }
      }
    }
    return false;
  }
  
  private checkPatternAtPosition(grid: Symbol[][], pattern: Pattern, startRow: number, startCol: number): boolean {
    // Generate positions dynamically based on pattern type and length
    const positions = this.generatePatternPositions(pattern, startRow, startCol);
    
    // Check if all positions are valid and symbols match
    for (const [row, col] of positions) {
      if (row >= grid.length || col >= grid[row].length) {
        return false; // Pattern goes out of bounds
      }
      
      if (!this.symbolsMatch(grid[startRow][startCol], grid[row][col])) {
        return false;
      }
    }
    return true;
  }
}
```

### Performance Characteristics
- **Pattern generation**: 0ms (patterns are pre-defined)
- **Pattern extension**: < 1ms (simple array mapping)
- **Pattern matching**: < 5ms (max 20 patterns to check)
- **Memory usage**: < 1MB (tiny pattern list)
- **No caching needed**: Patterns are always in memory
- **No background workers**: Everything is instant

## Simple Implementation Phases

### Phase 1: Core System
1. Create basic pattern types (horizontal, vertical, diagonal)
2. Implement pattern extension logic
3. Add simple pattern matching
4. Test with 3x3 grid

### Phase 2: Grid Expansion
1. Add charm system for grid expansion
2. Implement pattern extension on grid change
3. Add pattern matching after expansion
4. Test with various grid sizes

### Phase 3: UI/UX
1. Show active patterns to player
2. Display pattern matches with coins
3. Add visual feedback for grid expansion
4. Test complete gameplay loop

### Phase 4: Polish
1. Add more pattern types (L-shape, T-shape)
2. Balance coin values
3. Add sound effects
4. Final testing and bug fixes

**Total Development Time: 1-2 weeks (vs 2-3 months for complex system)**

## Step-by-Step Implementation Guide

### Phase 1: Core Pattern System (Days 1-3)

#### Step 1.1: Create Pattern Data Structure
```typescript
// File: src/types/Pattern.ts
interface Pattern {
  name: string;
  type: 'horizontal' | 'vertical' | 'diagonal' | 'anti-diagonal' | 'L-shape' | 'T-shape';
  length: number;
  multiplier: number;
}

// File: src/data/BasePatterns.ts
export const BASE_PATTERNS: Pattern[] = [
  { name: 'horizontal-3', type: 'horizontal', length: 3, multiplier: 1.0 },
  { name: 'vertical-3', type: 'vertical', length: 3, multiplier: 1.0 },
  { name: 'diagonal-3', type: 'diagonal', length: 3, multiplier: 1.2 },
  { name: 'anti-diagonal-3', type: 'anti-diagonal', length: 3, multiplier: 1.2 }
];
```

#### Step 1.2: Implement Pattern Manager
```typescript
// File: src/systems/PatternManager.ts
export class PatternManager {
  private patterns: Pattern[] = [];
  private currentGridSize = { rows: 3, cols: 3 };
  
  initialize() {
    this.patterns = [...BASE_PATTERNS];
  }
  
  getActivePatterns(): Pattern[] {
    return this.patterns;
  }
  
  onGridExpand(direction: 'row' | 'col', amount: number = 1) {
    if (direction === 'row') {
      this.currentGridSize.rows += amount;
    } else {
      this.currentGridSize.cols += amount;
    }
    
    this.extendPatterns();
  }
  
  private extendPatterns() {
    this.patterns = this.patterns.map(pattern => {
      if (this.canExtend(pattern)) {
        return this.extendPattern(pattern);
      }
      return pattern;
    });
  }
  
  private canExtend(pattern: Pattern): boolean {
    // Only extend line patterns, not shapes
    return ['horizontal', 'vertical', 'diagonal', 'anti-diagonal'].includes(pattern.type);
  }
  
  private extendPattern(pattern: Pattern): Pattern {
    const newLength = pattern.length + 1;
    return {
      ...pattern,
      name: `${pattern.type}-${newLength}`,
      length: newLength,
      multiplier: this.calculateMultiplier(newLength, pattern.type)
    };
  }
  
  private calculateMultiplier(length: number, type: string): number {
    const baseMultipliers = {
      'horizontal': 1.0,
      'vertical': 1.0,
      'diagonal': 1.2,
      'anti-diagonal': 1.2,
      'L-shape': 1.5,
      'T-shape': 1.5
    };
    
    const typeBonus = baseMultipliers[type] || 1.0;
    const lengthBonus = Math.pow(1.2, length - 3);
    return typeBonus * lengthBonus;
  }
}
```

#### Step 1.3: Implement Pattern Matcher
```typescript
// File: src/systems/PatternMatcher.ts
export class PatternMatcher {
  findMatches(grid: Symbol[][], patterns: Pattern[]): Pattern[] {
    const matches: Pattern[] = [];
    
    for (const pattern of patterns) {
      if (this.checkPatternMatch(grid, pattern)) {
        matches.push(pattern);
      }
    }
    
    return matches;
  }
  
  private checkPatternMatch(grid: Symbol[][], pattern: Pattern): boolean {
    for (let row = 0; row < grid.length; row++) {
      for (let col = 0; col < grid[row].length; col++) {
        if (this.checkPatternAtPosition(grid, pattern, row, col)) {
          return true;
        }
      }
    }
    return false;
  }
  
  private checkPatternAtPosition(
    grid: Symbol[][], 
    pattern: Pattern, 
    startRow: number, 
    startCol: number
  ): boolean {
    const positions = this.generatePatternPositions(pattern, startRow, startCol);
    
    for (const [row, col] of positions) {
      if (row >= grid.length || col >= grid[row].length) {
        return false;
      }
      
      if (!this.symbolsMatch(grid[startRow][startCol], grid[row][col])) {
        return false;
      }
    }
    return true;
  }
  
  private generatePatternPositions(pattern: Pattern, startRow: number, startCol: number): number[][] {
    const positions: number[][] = [];
    
    switch (pattern.type) {
      case 'horizontal':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow, startCol + i]);
        }
        break;
      case 'vertical':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow + i, startCol]);
        }
        break;
      case 'diagonal':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow + i, startCol + i]);
        }
        break;
      case 'anti-diagonal':
        for (let i = 0; i < pattern.length; i++) {
          positions.push([startRow + i, startCol - i]);
        }
        break;
    }
    
    return positions;
  }
  
  private symbolsMatch(symbol1: Symbol, symbol2: Symbol): boolean {
    return symbol1.type === symbol2.type;
  }
}
```

### Phase 2: Grid System Integration (Days 4-5)

#### Step 2.1: Update Grid System
```typescript
// File: src/systems/GridSystem.ts
export class GridSystem {
  private patternManager: PatternManager;
  private patternMatcher: PatternMatcher;
  private currentGrid: Symbol[][];
  
  constructor() {
    this.patternManager = new PatternManager();
    this.patternMatcher = new PatternMatcher();
    this.patternManager.initialize();
  }
  
  expandGrid(direction: 'row' | 'col', amount: number = 1) {
    // Update grid size
    this.updateGridSize(direction, amount);
    
    // Extend patterns
    this.patternManager.onGridExpand(direction, amount);
    
    // Check for new matches
    this.checkForMatches();
  }
  
  private updateGridSize(direction: 'row' | 'col', amount: number) {
    if (direction === 'row') {
      // Add new row
      const newRow = this.generateRandomRow();
      this.currentGrid.push(newRow);
    } else {
      // Add new column to each row
      this.currentGrid.forEach(row => {
        row.push(this.generateRandomSymbol());
      });
    }
  }
  
  private checkForMatches() {
    const activePatterns = this.patternManager.getActivePatterns();
    const matches = this.patternMatcher.findMatches(this.currentGrid, activePatterns);
    
    if (matches.length > 0) {
      this.awardCoins(matches);
      this.showMatchFeedback(matches);
    }
  }
  
  private awardCoins(matches: Pattern[]) {
    let totalCoins = 0;
    for (const match of matches) {
      totalCoins += Math.floor(match.multiplier * 10); // Base 10 coins per multiplier
    }
    
    // Update game state
    this.addCoins(totalCoins);
  }
}
```

#### Step 2.2: Update Charm System
```typescript
// File: src/systems/CharmSystem.ts
export class CharmSystem {
  private gridSystem: GridSystem;
  
  constructor(gridSystem: GridSystem) {
    this.gridSystem = gridSystem;
  }
  
  activateCharm(charmId: string) {
    const charm = this.getCharm(charmId);
    
    switch (charm.effect) {
      case 'expand_cols':
        this.gridSystem.expandGrid('col', charm.amount);
        break;
      case 'expand_rows':
        this.gridSystem.expandGrid('row', charm.amount);
        break;
      case 'expand_both':
        this.gridSystem.expandGrid('col', charm.amount);
        this.gridSystem.expandGrid('row', charm.amount);
        break;
    }
  }
  
  private getCharm(charmId: string) {
    const charms = {
      'wide-vision': { effect: 'expand_cols', amount: 1 },
      'tall-ambition': { effect: 'expand_rows', amount: 1 },
      'big-expansion': { effect: 'expand_both', amount: 1 }
    };
    
    return charms[charmId];
  }
}
```

### Phase 3: UI Integration (Days 6-7)

#### Step 3.1: Pattern Display Component
```typescript
// File: src/components/PatternDisplay.tsx
export const PatternDisplay: React.FC = () => {
  const { activePatterns } = useGameState();
  
  return (
    <div className="pattern-display">
      <h3>Active Patterns</h3>
      {activePatterns.map(pattern => (
        <div key={pattern.name} className="pattern-item">
          <span className="pattern-name">{pattern.name}</span>
          <span className="pattern-multiplier">{pattern.multiplier}x</span>
        </div>
      ))}
    </div>
  );
};
```

#### Step 3.2: Match Feedback Component
```typescript
// File: src/components/MatchFeedback.tsx
export const MatchFeedback: React.FC<{ matches: Pattern[] }> = ({ matches }) => {
  return (
    <div className="match-feedback">
      {matches.map(match => (
        <div key={match.name} className="match-item">
          <span>🎉 {match.name} - {match.multiplier}x coins!</span>
        </div>
      ))}
    </div>
  );
};
```

### Phase 4: Testing & Polish (Days 8-10)

#### Step 4.1: Unit Tests
```typescript
// File: src/tests/PatternManager.test.ts
describe('PatternManager', () => {
  test('should extend patterns when grid expands', () => {
    const manager = new PatternManager();
    manager.initialize();
    
    const initialPatterns = manager.getActivePatterns();
    expect(initialPatterns).toHaveLength(4);
    
    manager.onGridExpand('col', 1);
    const extendedPatterns = manager.getActivePatterns();
    
    // Should have extended horizontal patterns
    const horizontal4 = extendedPatterns.find(p => p.name === 'horizontal-4');
    expect(horizontal4).toBeDefined();
    expect(horizontal4?.multiplier).toBe(1.2);
  });
});
```

#### Step 4.2: Integration Tests
```typescript
// File: src/tests/GridSystem.test.ts
describe('GridSystem', () => {
  test('should find matches after grid expansion', () => {
    const gridSystem = new GridSystem();
    
    // Set up grid with matching symbols
    gridSystem.setGrid([
      [symbol1, symbol1, symbol1],
      [symbol2, symbol3, symbol4],
      [symbol5, symbol6, symbol7]
    ]);
    
    // Expand grid
    gridSystem.expandGrid('col', 1);
    
    // Should find horizontal-3 match
    const matches = gridSystem.getLastMatches();
    expect(matches).toHaveLength(1);
    expect(matches[0].name).toBe('horizontal-3');
  });
});
```

## Current Implementation Analysis

### ✅ **Already Implemented (Keep as-is):**
- Basic grid system structure
- Symbol generation and display
- Charm system framework
- UI components for grid display

### 🔄 **Needs Rework/Update:**
- **Pattern System**: Replace complex pattern generation with simple pattern types
- **Grid Expansion**: Update to use new pattern extension logic
- **Match Detection**: Replace with efficient loop-based checking
- **Charm Effects**: Update to use new grid expansion system

### 🆕 **Needs to be Added:**
- Pattern data structures
- Pattern manager class
- Pattern matcher class
- Pattern display UI
- Match feedback system
- Unit tests for pattern system

### 📋 **Implementation Checklist:**

#### Day 1-2: Core Pattern System
- [ ] Create Pattern interface
- [ ] Implement PatternManager class
- [ ] Implement PatternMatcher class
- [ ] Add base pattern data
- [ ] Write unit tests

#### Day 3-4: Grid Integration
- [ ] Update GridSystem to use PatternManager
- [ ] Update CharmSystem to use new grid expansion
- [ ] Integrate pattern matching with grid updates
- [ ] Test grid expansion with pattern extension

#### Day 5-6: UI Integration
- [ ] Create PatternDisplay component
- [ ] Create MatchFeedback component
- [ ] Update existing UI to show patterns
- [ ] Add visual feedback for matches

#### Day 7-8: Testing & Polish
- [ ] Write integration tests
- [ ] Test complete gameplay loop
- [ ] Fix bugs and edge cases
- [ ] Add sound effects for matches

#### Day 9-10: Final Polish
- [ ] Balance pattern multipliers
- [ ] Add more pattern types (L-shape, T-shape)
- [ ] Optimize performance
- [ ] Final testing and deployment

### 🚀 **Quick Start Implementation:**

1. **Start with PatternManager** - This is the core of the system
2. **Test with simple 3x3 grid** - Make sure basic patterns work
3. **Add grid expansion** - Test pattern extension
4. **Add UI feedback** - Show patterns and matches to player
5. **Integrate with charms** - Connect to existing charm system

This approach will give you a working pattern system in 1-2 weeks that's much simpler and more efficient than the original complex design!
