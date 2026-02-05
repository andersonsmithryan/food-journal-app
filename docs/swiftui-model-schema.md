# SwiftUI Model Schema (Pre-Migration)

## Purpose
Define the canonical SwiftUI-side data model before UI migration begins.

## Core Models

### JournalLog
- `version: Int`
- `entries: [JournalEntry]`

### JournalEntry
- `id: String`
- `isoDate: String`
- `displayDate: String`
- `notesForToday: String`
- `preMealState: SymptomState`
- `preMealTime: String`
- `preMealApprox: Bool`
- `preMealLocked: Bool`
- `meals: [Meal]`
- `createdAt: String`
- `updatedAt: String`

### Meal
- `id: String`
- `index: Int`
- `type: MealType`
- `timeEaten: String?`
- `timeApprox: Bool`
- `mealName: String`
- `portionSize: Quantity`
- `notes: [MealNote]`
- `reheatedDays: Int?`
- `finished: Bool`
- `symptomChange: SymptomChange`
- `symptomTime: String?`
- `symptomApprox: Bool`
- `symptoms: SymptomState`
- `digestion: SymptomState`
- `macros: MacroState`
- `timeline: [TimelineEvent]`
- `components: [Component]`

### Component
- `id: String`
- `name: String`
- `quantity: Quantity`
- `allergens: [String]`
- `ingredientType: IngredientType`
- `ingredients: [Ingredient]`

### Ingredient
- `id: String`
- `name: String`
- `brandSource: String`
- `quantity: Quantity`
- `subIngredients: [String]`
- `allergens: [String]`

### Quantity
- `amount: String`
- `unit: String`

### MacroState
- `fat: String`
- `protein: String`
- `carbs: String`
- `fibre: String`

### TimelineEvent
- `id: String`
- `symptomLabel: String`
- `eventTime: String`
- `onsetMinutes: Int`

### SymptomState
- Dynamic key/value map keyed by `symptoms.json` keys.
- Values support `Int`, `Bool`, `String`, and `nil` (for cleared post-meal state).

## Supporting Enums
- `MealType`: Breakfast / Lunch / Dinner / Snack / Beverage
- `IngredientType`: Single / Prepared / Packaged
- `SymptomChange`: Yes / No / Unknown
- `MealNote`: Fresh / Take-Away / Restaurant / Packaged / Reheated

## Compatibility Notes
- Preserve decoding support for legacy fields (`preparation`, `prepType`, etc.) during transition.
- Keep custom decoding paths for older quantity/unit formats.

## Migration Rule
UI must bind directly to these models (`@State`, `@Binding`, `ObservableObject`) and avoid DOM-style derived state.
