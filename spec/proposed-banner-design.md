Of course. Here are the design proposals for all three states of the Unified Health Summary card, including the new empty state.

---

### **1. Empty State / Welcome Card**

This card appears when the user has no lab reports or health logs. Its goal is to guide them to take their first action.

**A. Structure & Appearance**
A `Card` with a neutral background color. It could optionally have a subtle dashed border to signify it as a placeholder or call to action.

**B. Content Layout**
A simple, centered layout focusing on the call to action.

*   **(Icon)**: A large, encouraging icon at the top, like `Icons.add_circle_outline` or `Icons.upload_file_outlined`.
*   **(Headline Text)**: A welcoming headline.
    *   **Text**: "Welcome!"
    *   **Style**: Bold, `titleLarge`.
*   **(Body Text)**: A concise instruction.
    *   **Text**: "Upload your first lab report to see your health summary."
    *   **Style**: `bodyMedium`, centered text.

**C. Conceptual Mockup**
```
+------------------------------------------------------+
|                                                      |
|                          +                           |
|                                                      |
|                        Welcome!                      |
|         Upload your first lab report to see          |
|                 your health summary.                 |
|                                                      |
+------------------------------------------------------+
```

---

### **2. "All Clear" State Card**

This card appears when the user has data, and all recent vitals and biomarkers are within their normal reference ranges.

**A. Structure & Appearance**
A `Card` with a light, reassuring green background (e.g., `Colors.green.shade50`).

**B. Content Layout**
The layout provides a quick confirmation that everything is normal.

*   **Header**:
    *   **Icon**: `Icons.check_circle_outline_rounded` in a strong green color.
    *   **Text**: "All Clear", styled to be bold and prominent.
*   **Detailed Counts**:
    *   **Vitals**: "❤️ Vitals" with the count "0 in Warning" in a neutral/subtle color.
    *   **Biomarkers**: "🧪 Biomarkers" with the count "0 Out of Range" in a neutral/subtle color.
*   **Footer**:
    *   **Text**: "Last update: Yesterday, 5:00 PM", right-aligned and subtle.

**C. Conceptual Mockup**
```
+------------------------------------------------------+
| 🟢 All Clear                                         |
|                                                      |
| ❤️ Vitals                🧪 Biomarkers               |
| 0 in Warning             0 Out of Range              |
|                                                      |
|                        Last update: Yesterday, 5:00 PM |
+------------------------------------------------------+
```

---

### **3. "Attention Needed" State Card**

This card appears when any recent vital or biomarker is outside its normal range, immediately drawing the user's attention to important health data.

**A. Structure & Appearance**
A `Card` with a light, cautionary orange or yellow background (e.g., `Colors.orange.shade50`).

**B. Content Layout**
The layout highlights the specific areas that require attention.

*   **Header**:
    *   **Icon**: `Icons.warning_amber_rounded` in a strong orange color.
    *   **Text**: "Attention Needed", styled to be bold and prominent.
*   **Detailed Counts**:
    *   **Vitals**: "❤️ Vitals" with the count "2 in Warning". The count text is colored orange to match the warning theme.
    *   **Biomarkers**: "🧪 Biomarkers" with the count "4 Out of Range". The count text is also colored orange.
*   **Footer**:
    *   **Text**: "Last update: Today, 9:30 AM", right-aligned and subtle.

**C. Conceptual Mockup**
```
+------------------------------------------------------+
| 🟠 Attention Needed                                  |
|                                                      |
| ❤️ Vitals                🧪 Biomarkers               |
| 2 in Warning             4 Out of Range              |
|                                                      |
|                        Last update: Today, 9:30 AM   |
+------------------------------------------------------+
```