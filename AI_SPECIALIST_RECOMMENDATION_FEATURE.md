# AI Assistant Specialist Recommendation Feature

## Overview

The AI Assistant now displays recommended specialists in a beautiful, interactive card format that matches the home page category design. When the AI analyzes symptoms and recommends a specialist, users can tap the card to view available doctors for that specialty.

## Features

### 1. **Visual Specialist Card**

- **Icon & Color-Coded**: Each specialty has a unique icon and color matching the home page categories
- **Specialist Name**: Clearly displays the recommended specialist type
- **Reasoning Section**: Shows WHY this specialist is recommended based on symptoms
- **Call-to-Action Button**: "View Doctors" button for easy navigation

### 2. **Supported Specializations**

The system recognizes and routes to these specialties:

- Cardiologist (Heart & Cardiovascular)
- Dermatologist (Skin Conditions)
- Neurologist (Neurological Issues)
- Orthopedist (Bones & Joints)
- Gynecologist & Obstetrician
- Psychiatrist (Mental Health)
- Pediatrician (Children's Health)
- Dentist (Oral Health)
- ENT Specialist (Ear, Nose, Throat)
- General Physician
- Gastroenterologist (Digestive System)
- Ophthalmologist (Eye Care)
- Pulmonologist (Respiratory)
- Endocrinologist (Hormones, Diabetes)
- Urologist (Urinary System)
- And 20+ more specializations

### 3. **Navigation Flow**

```
User describes symptoms
    ↓
AI analyzes and recommends specialist
    ↓
Beautiful card appears with:
  - Icon + Color
  - Specialist name
  - Reasoning explanation
  - "View Doctors" button
    ↓
User taps card
    ↓
Navigates to DoctorsBySpecialtyPage
    ↓
Shows available doctors for that specialty
```

## Implementation Details

### Files Modified/Created

1. **specialist_recommendation_card.dart** (NEW)

   - Path: `lib/features/ai_assistant/presentation/widgets/specialist_recommendation_card.dart`
   - Beautiful card widget with icon, color, and reasoning
   - Matches home page category design
   - Responsive and interactive

2. **symptom_analysis.dart** (UPDATED)

   - Added `reasoning` field to store WHY a specialist is recommended
   - Enhanced parsing to extract reasoning from AI response
   - Better multi-line text handling

3. **ai_chat_provider.dart** (UPDATED)

   - Added `reasoning` to ChatState
   - Passes reasoning from analysis to UI
   - Maintains state across chat sessions

4. **ai_assistant_page.dart** (UPDATED)
   - Replaced old chip with new SpecialistRecommendationCard
   - Cleaner UI with better visual hierarchy
   - Same navigation logic maintained

### Icon & Color Mapping

The card automatically assigns appropriate icons and colors:

```dart
Cardiology → Red Heart Pulse icon
Neurology → Purple Brain icon
Dermatology → Green Bacteria icon
Orthopedics → Brown Bone icon
Pediatrics → Teal Baby icon
// ... and more
```

### AI Prompt Enhancement

The AI is prompted to provide responses in this format:

```
## 🔍 Possible Conditions
- List of likely conditions

## 👨‍⚕️ Recommended Specialist
**Specialist Type:** [Specific specialty name]
**Reasoning:** [Why this specialist is recommended]

## 💡 Medical Advice
- Immediate care recommendations
- Self-care tips
```

## User Experience

### Before (Old Design)

- Simple purple chip with white text
- Just showed specialist name
- No visual cues or icons
- No explanation of why

### After (New Design)

- Beautiful gradient card with shadows
- Color-coded by specialty
- FontAwesome icon for visual recognition
- "Why this specialist?" reasoning section
- Clear "View Doctors" call-to-action button
- Matches home page category aesthetics

## Testing

### Test Scenarios

1. **Cardiology Symptoms**

   - Input: "I have chest pain and shortness of breath"
   - Expected: Red card with heart icon for "Cardiologist"
   - Reasoning: Explains cardiac symptoms connection

2. **Dermatology Symptoms**

   - Input: "I have a rash on my arm that's itchy"
   - Expected: Green card with bacteria icon for "Dermatologist"
   - Reasoning: Explains skin condition specialist need

3. **Neurologist Symptoms**

   - Input: "Severe headaches and dizziness"
   - Expected: Purple card with brain icon for "Neurologist"
   - Reasoning: Explains neurological symptom analysis

4. **Navigation Test**
   - Tap on specialist card
   - Should navigate to DoctorsBySpecialtyPage
   - Should show doctors with that specialization
   - Back button should return to AI chat

## Benefits

✅ **Visual Consistency**: Matches home page category design
✅ **Better UX**: Clear call-to-action with visual feedback
✅ **Informative**: Explains WHY a specialist is recommended
✅ **Intuitive**: Icons and colors help quick recognition
✅ **Professional**: Polished, medical-grade appearance
✅ **Accessible**: Clear typography and contrast

## Future Enhancements

- [ ] Add doctor availability indicator on card
- [ ] Show estimated wait time per specialty
- [ ] Add "Book Immediately" quick action
- [ ] Multiple specialist recommendations if symptoms overlap
- [ ] Severity indicator (urgent vs. routine)
- [ ] Local specialist search based on user location

## Example Output

When user says: "I have been experiencing severe headaches and occasional blurred vision for the past week"

AI Response Card shows:

```
🧠 [Purple Brain Icon in rounded box]

🟢 Recommended Specialist
NEUROLOGIST

[View Doctors →] (Purple button)

💡 Why this specialist?
Based on your symptoms of severe headaches combined with vision
changes, a neurologist can properly evaluate potential neurological
conditions and provide appropriate treatment. The combination of
these symptoms requires specialized neurological assessment.
```

## Code Example

```dart
// The card automatically appears when AI recommends a specialist
if (chatState.recommendedSpecialization != null)
  SpecialistRecommendationCard(
    specialization: chatState.recommendedSpecialization!,
    reasoning: chatState.reasoning,
    onTap: () => _navigateToSpecialist(
      chatState.recommendedSpecialization!,
    ),
  ),
```

## Dependencies

- font_awesome_flutter: For specialist icons
- flutter_riverpod: State management
- google_generative_ai: AI analysis

---

**Created**: October 18, 2025
**Version**: 1.0.0
**Status**: ✅ Implemented and Ready
