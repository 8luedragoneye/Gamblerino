# Dynamic Pattern System Design

## Overview
A completely flexible pattern generation system that automatically discovers and values patterns based on any grid size, controlled by charms and phone calls.

## Core Concepts

### 1. Flexible Grid Sizing
- **Any dimensions**: 3x3, 4x4, 3x9, 7x2, 1x10, 6x6, etc.
- **Individual control**: Add rows and columns separately
- **Charm/Phone Call driven**: Grid size changes through game mechanics, not levels

### 2. Dynamic Pattern Discovery
- **No hardcoded patterns**: System generates patterns algorithmically
- **Size-adaptive**: Patterns automatically adjust to grid dimensions
- **Comprehensive scanning**: Finds ALL possible patterns for any grid size

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

### Pattern Discovery Algorithm

#### Core Pattern Generator
```typescript
interface PatternGenerator {
  generatePatterns(gridSize: {rows: number, cols: number}): Pattern[];
  generateLinePatterns(rows: number, cols: number): Pattern[];
  generateDiagonalPatterns(rows: number, cols: number): Pattern[];
  generateGeometricPatterns(rows: number, cols: number): Pattern[];
  generateCustomPatterns(rows: number, cols: number): Pattern[];
}

interface Pattern {
  name: string;
  positions: number[][];
  baseMultiplier: number;
  difficulty: number;
  type: 'line' | 'diagonal' | 'geometric' | 'custom';
  rarity: number;
}
```

#### Line Pattern Generation
```typescript
const generateLinePatterns = (rows: number, cols: number) => {
  const patterns: Pattern[] = [];
  
  // Horizontal lines (all possible lengths)
  for (let row = 0; row < rows; row++) {
    for (let length = 3; length <= cols; length++) {
      for (let startCol = 0; startCol <= cols - length; startCol++) {
        const positions = Array.from({length}, (_, i) => [row, startCol + i]);
        patterns.push({
          name: `H-${row}-${length}`,
          positions,
          baseMultiplier: calculateMultiplier(length, 'horizontal'),
          difficulty: length,
          type: 'line',
          rarity: calculateRarity(length, cols)
        });
      }
    }
  }
  
  // Vertical lines (all possible lengths)
  for (let col = 0; col < cols; col++) {
    for (let length = 3; length <= rows; length++) {
      for (let startRow = 0; startRow <= rows - length; startRow++) {
        const positions = Array.from({length}, (_, i) => [startRow + i, col]);
        patterns.push({
          name: `V-${col}-${length}`,
          positions,
          baseMultiplier: calculateMultiplier(length, 'vertical'),
          difficulty: length,
          type: 'line',
          rarity: calculateRarity(length, rows)
        });
      }
    }
  }
  
  return patterns;
};
```

#### Diagonal Pattern Generation
```typescript
const generateDiagonalPatterns = (rows: number, cols: number) => {
  const patterns: Pattern[] = [];
  
  // Main diagonals (top-left to bottom-right)
  for (let startRow = 0; startRow <= rows - 3; startRow++) {
    for (let startCol = 0; startCol <= cols - 3; startCol++) {
      const maxLength = Math.min(rows - startRow, cols - startCol);
      for (let length = 3; length <= maxLength; length++) {
        const positions = Array.from({length}, (_, i) => [startRow + i, startCol + i]);
        patterns.push({
          name: `D-${startRow}-${startCol}-${length}`,
          positions,
          baseMultiplier: calculateMultiplier(length, 'diagonal'),
          difficulty: length,
          type: 'diagonal',
          rarity: calculateRarity(length, Math.min(rows, cols))
        });
      }
    }
  }
  
  // Anti-diagonals (top-right to bottom-left)
  for (let startRow = 0; startRow <= rows - 3; startRow++) {
    for (let startCol = 2; startCol < cols; startCol++) {
      const maxLength = Math.min(rows - startRow, startCol + 1);
      for (let length = 3; length <= maxLength; length++) {
        const positions = Array.from({length}, (_, i) => [startRow + i, startCol - i]);
        patterns.push({
          name: `AD-${startRow}-${startCol}-${length}`,
          positions,
          baseMultiplier: calculateMultiplier(length, 'diagonal'),
          difficulty: length,
          type: 'diagonal',
          rarity: calculateRarity(length, Math.min(rows, cols))
        });
      }
    }
  }
  
  return patterns;
};
```

#### Geometric Pattern Generation
```typescript
const generateGeometricPatterns = (rows: number, cols: number) => {
  const patterns: Pattern[] = [];
  
  // L-shapes (all possible sizes and orientations)
  for (let size = 2; size <= Math.min(rows, cols) - 1; size++) {
    for (let row = 0; row <= rows - size - 1; row++) {
      for (let col = 0; col <= cols - size - 1; col++) {
        // 4 orientations of L-shape
        const orientations = [
          // L pointing right-down
          [[0,0], [0,1], [1,0]],
          // L pointing down-left  
          [[0,1], [1,1], [1,0]],
          // L pointing left-up
          [[1,1], [1,0], [0,1]],
          // L pointing up-right
          [[1,0], [0,0], [0,1]]
        ];
        
        orientations.forEach((shape, i) => {
          const positions = shape.map(([r, c]) => [row + r, col + c]);
          patterns.push({
            name: `L-${size}-${i}-${row}-${col}`,
            positions,
            baseMultiplier: calculateMultiplier(positions.length, 'geometric'),
            difficulty: positions.length,
            type: 'geometric',
            rarity: calculateRarity(positions.length, Math.min(rows, cols))
          });
        });
      }
    }
  }
  
  // T-shapes
  for (let size = 2; size <= Math.min(rows, cols) - 1; size++) {
    for (let row = 0; row <= rows - size - 1; row++) {
      for (let col = 0; col <= cols - size - 1; col++) {
        const tShapes = [
          // T pointing up
          [[0,1], [1,0], [1,1], [1,2], [2,1]],
          // T pointing right
          [[0,0], [0,1], [0,2], [1,1], [2,1]],
          // T pointing down
          [[0,1], [1,0], [1,1], [1,2], [2,1]],
          // T pointing left
          [[0,1], [1,0], [1,1], [1,2], [2,1]]
        ];
        
        tShapes.forEach((shape, i) => {
          const positions = shape.map(([r, c]) => [row + r, col + c]);
          if (isValidPattern(positions, rows, cols)) {
            patterns.push({
              name: `T-${size}-${i}-${row}-${col}`,
              positions,
              baseMultiplier: calculateMultiplier(positions.length, 'geometric'),
              difficulty: positions.length,
              type: 'geometric',
              rarity: calculateRarity(positions.length, Math.min(rows, cols))
            });
          }
        });
      }
    }
  }
  
  return patterns;
};
```

### Pattern Valuation System

#### Multiplier Calculation
```typescript
const calculateMultiplier = (length: number, type: 'horizontal' | 'vertical' | 'diagonal' | 'geometric') => {
  const baseMultipliers = {
    horizontal: 1.0,
    vertical: 1.0,
    diagonal: 1.2,
    geometric: 1.5
  };
  
  const lengthBonus = Math.pow(1.2, length - 3); // 20% bonus per extra symbol
  const typeBonus = baseMultipliers[type];
  
  return typeBonus * lengthBonus;
};
```

#### Rarity Calculation
```typescript
const calculateRarity = (length: number, maxDimension: number) => {
  // Longer patterns in smaller grids are rarer
  const rarityFactor = length / maxDimension;
  return Math.pow(2, rarityFactor * 3); // Exponential rarity scaling
};
```

#### Pattern Complexity Scoring
```typescript
const calculatePatternComplexity = (positions: number[][]) => {
  const bounds = getBounds(positions);
  const area = bounds.width * bounds.height;
  const coverage = positions.length / area;
  const spread = calculateSpread(positions);
  
  return {
    area,
    coverage,
    spread,
    complexity: (coverage * spread) / area
  };
};
```

### Pattern Filtering & Balancing

#### Pattern Filter
```typescript
interface PatternFilter {
  maxPatterns: number;
  difficultyRange: [number, number];
  excludeTypes?: string[];
  preferRare?: boolean;
  minRarity?: number;
}

const filterPatterns = (patterns: Pattern[], filter: PatternFilter) => {
  return patterns
    .filter(p => p.difficulty >= filter.difficultyRange[0] && 
                 p.difficulty <= filter.difficultyRange[1])
    .filter(p => !filter.excludeTypes?.includes(p.type))
    .filter(p => !filter.minRarity || p.rarity >= filter.minRarity)
    .sort((a, b) => {
      if (filter.preferRare) {
        return b.rarity - a.rarity;
      }
      return b.baseMultiplier - a.baseMultiplier;
    })
    .slice(0, filter.maxPatterns);
};
```

### Charm-Based Pattern Modifiers

#### Pattern Modifier Charms
```typescript
interface PatternModifierCharm {
  id: string;
  name: string;
  effects: {
    patternTypes?: string[]; // Only affect certain pattern types
    multiplierBonus?: number; // Add to pattern multiplier
    difficultyModifier?: number; // Make patterns easier/harder
    unlockNewTypes?: string[]; // Unlock new pattern types
    gridSizeModifier?: { rows: number, cols: number };
  };
}

const patternCharms = {
  'geometric-master': {
    effects: {
      patternTypes: ['geometric'],
      multiplierBonus: 0.5,
      unlockNewTypes: ['spiral', 'zigzag']
    }
  },
  'line-specialist': {
    effects: {
      patternTypes: ['line'],
      multiplierBonus: 0.3,
      difficultyModifier: -1 // Makes line patterns easier
    }
  },
  'wide-vision': {
    effects: {
      gridSizeModifier: { rows: 0, cols: +2 }
    }
  },
  'tall-ambition': {
    effects: {
      gridSizeModifier: { rows: +2, cols: 0 }
    }
  }
};
```

### Real-time Pattern Updates

#### Grid Size Change Handler
```typescript
const updatePatternsForGridSize = (newGridSize: {rows: number, cols: number}) => {
  const newPatterns = generatePatterns(newGridSize);
  const filteredPatterns = filterPatterns(newPatterns, currentFilter);
  
  // Update game state with new patterns
  setAvailablePatterns(filteredPatterns);
  
  // Recalculate existing matches with new patterns
  const currentMatches = findMatchingPatterns(currentGrid, filteredPatterns);
  updateMatches(currentMatches);
};
```

## Example Scenarios

### Scenario 1: 3x9 Grid
**Grid:**
```
🍋 🍒 🍀 🔔 💎 💰 7️⃣ 🍋 🍒
🔔 💎 💰 7️⃣ 🍋 🍒 🍀 🔔 💎
7️⃣ 🍋 🍒 🍀 🔔 💎 💰 7️⃣ 🍋
```

**Discovered Patterns:**
- 9-symbol horizontal lines: 50 coins (very rare!)
- 8-symbol horizontal lines: 40 coins
- 7-symbol horizontal lines: 30 coins
- 6-symbol horizontal lines: 20 coins
- 5-symbol horizontal lines: 15 coins
- 4-symbol horizontal lines: 10 coins
- 3-symbol horizontal lines: 5 coins
- 3-symbol vertical lines: 8 coins
- 3-symbol diagonals: 12 coins
- L-shapes: 15-25 coins (various sizes)
- T-shapes: 12-20 coins (various sizes)

### Scenario 2: 7x2 Grid
**Grid:**
```
🍋 🍒
🔔 💎
💰 7️⃣
🍋 🍒
🔔 💎
💰 7️⃣
🍋 🍒
```

**Discovered Patterns:**
- 7-symbol vertical lines: 35 coins (very rare!)
- 6-symbol vertical lines: 28 coins
- 5-symbol vertical lines: 20 coins
- 4-symbol vertical lines: 15 coins
- 3-symbol vertical lines: 10 coins
- 2-symbol horizontal lines: 3 coins (very common)

### Scenario 3: 1x20 Grid
**Grid:**
```
🍋 🍒 🍀 🔔 💎 💰 7️⃣ 🍋 🍒 🍀 🔔 💎 💰 7️⃣ 🍋 🍒 🍀 🔔 💎
```

**Discovered Patterns:**
- 20-symbol horizontal line: 100 coins (extremely rare!)
- 19-symbol horizontal line: 90 coins
- 18-symbol horizontal line: 80 coins
- ...and so on down to 3-symbol lines

## Benefits

### 1. Complete Flexibility
- Any grid size works automatically
- No hardcoded pattern limitations
- Patterns adapt to player's grid choices

### 2. Dynamic Balancing
- Values automatically adjust based on difficulty
- Rarer patterns in smaller grids worth more
- Longer patterns in larger grids worth more

### 3. Charm Integration
- Charms directly affect gameplay mechanics
- Grid size changes feel meaningful
- Temporary effects create variety

### 4. Scalable System
- Easy to add new pattern types
- Easy to add new grid size modifiers
- Easy to balance through parameters

### 5. Player Agency
- Players choose their grid size through charms
- Risk/reward decisions (smaller grid = easier patterns, bigger grid = harder but more valuable)
- Phone calls provide temporary strategic options

## Implementation Phases

### Phase 1: Core System
1. Implement flexible grid sizing
2. Create pattern discovery algorithms
3. Implement automatic valuation system

### Phase 2: Charm Integration
1. Add grid size modifier charms
2. Add pattern modifier charms
3. Integrate with existing charm system

### Phase 3: Phone Call Integration
1. Add grid size phone call effects
2. Add pattern discovery phone call effects
3. Integrate with existing phone call system

### Phase 4: UI/UX
1. Update grid display for variable sizes
2. Show discovered patterns to player
3. Add pattern value indicators

### Phase 5: Balancing & Polish
1. Tune valuation parameters
2. Balance charm effects
3. Add visual feedback for pattern discovery
