# Accessible Forms & User Input

> A form without proper labels is like a classroom with no labels on the doors—anyone with sight can figure it out, but it's impossible for others.

**Type:** Learn
**Languages:** HTML
**Prerequisites:** 01-document-structure-metadata, 02-semantic-html5-elements
**Time:** ~55 minutes

## Learning Objectives

- Associate labels with form inputs for accessibility
- Use modern HTML input types for validation and mobile UX
- Organize complex forms with fieldsets and legends
- Understand the semantic difference between buttons and links
- Build progressively enhancing forms

## The Problem

You fill out a form on a website using only your keyboard. You can't see the screen—you're using a screen reader. As you tab through fields, you hear "text input," "text input," "text input" with no context. You have no idea what each field is for.

This happens to real users every day. Forms without proper labels are inaccessible. But the problem goes beyond accessibility:

- Missing labels confuse everyone on slow mobile connections or when images don't load
- Wrong input types waste user effort (typing email format on a phone without an email keyboard)
- Invalid forms don't provide feedback
- Poorly organized forms are confusing, even with correct labels

Accessible forms aren't an afterthought—they're a core design responsibility.

## The Concept

A form is a conversation between the user and your application. The form elements must clearly communicate:
- **What** each field is for (label)
- **What format** is expected (input type, placeholder, hint)
- **What's required** (required attribute)
- **What went wrong** (validation feedback)

### The Anatomy of an Accessible Form Field

```
┌─────────────────────────────────────────┐
│ <label for="email">Email Address</label> │  ← Clear identifier
├─────────────────────────────────────────┤
│ <input                                  │  ← Properly typed
│   id="email"                            │     (email, tel, date)
│   type="email"                          │
│   name="email"                          │  ← Unique name
│   placeholder="user@example.com"        │     (hint, not label)
│   required                              │  ← Browser validation
│   aria-describedby="email-help"         │     (extra help)
│ />                                      │
│                                         │
│ <p id="email-help">                     │  ← Helper text
│   We'll never share your email.         │
│ </p>                                    │
└─────────────────────────────────────────┘
```

### Input Types and Their Superpowers

| Type | Mobile Keyboard | Browser Validation | Use When |
|------|-----------------|-------------------|----------|
| `text` | Alphanumeric | None | Generic text |
| `email` | Email keyboard (@) | Email format check | Email addresses |
| `tel` | Phone keyboard | None (format varies) | Phone numbers |
| `number` | Numeric | Number only | Quantities, ages |
| `date` | Date picker | Date format | Dates |
| `time` | Time picker | Time format | Times |
| `datetime-local` | Date + time picker | Both | Timestamps |
| `url` | URL keyboard (.) | URL format | Websites |
| `password` | Alphanumeric, masked | None | Passwords |
| `search` | Keyboard + search key | None | Search queries |
| `color` | Color picker | Hex format | Color selection |
| `range` | Slider | Min/max values | Scales (volume, brightness) |

## Build It

### Step 1: Simple Form with Proper Labels

```html
<form>
  <div>
    <label for="name">Full Name</label>
    <input id="name" type="text" name="name" required>
  </div>
  
  <div>
    <label for="email">Email Address</label>
    <input id="email" type="email" name="email" required>
  </div>
  
  <div>
    <label for="message">Message</label>
    <textarea id="message" name="message" rows="5" required></textarea>
  </div>
  
  <button type="submit">Send</button>
</form>
```

**Key principles:**
- Every `<input>` has a unique `id`
- Every `<label>` has a `for` attribute matching an input's `id`
- This association works for screen readers, improves click target on mobile, and enables CSS styling

### Step 2: Complex Form with Input Types and Validation

```html
<form>
  <fieldset>
    <legend>Create Your Account</legend>
    
    <div>
      <label for="username">Username</label>
      <input 
        id="username" 
        type="text" 
        name="username"
        pattern="^[a-zA-Z0-9_]{3,16}$"
        placeholder="alphanumeric, 3-16 characters"
        required
        aria-describedby="username-help"
      >
      <p id="username-help">Letters, numbers, and underscores only</p>
    </div>
    
    <div>
      <label for="email">Email</label>
      <input 
        id="email" 
        type="email" 
        name="email"
        required
      >
    </div>
    
    <div>
      <label for="phone">Phone (Optional)</label>
      <input 
        id="phone" 
        type="tel" 
        name="phone"
        placeholder="(123) 456-7890"
      >
    </div>
    
    <div>
      <label for="birthdate">Date of Birth</label>
      <input 
        id="birthdate" 
        type="date" 
        name="birthdate"
        required
      >
    </div>
    
    <div>
      <label for="experience">Experience Level (1-10)</label>
      <input 
        id="experience" 
        type="range" 
        name="experience"
        min="1" 
        max="10" 
        value="5"
        aria-describedby="experience-value"
      >
      <output id="experience-value">5</output>
    </div>
  </fieldset>
  
  <fieldset>
    <legend>Preferences</legend>
    
    <div>
      <input id="newsletter" type="checkbox" name="newsletter">
      <label for="newsletter">Subscribe to our newsletter</label>
    </div>
    
    <div>
      <input id="terms" type="checkbox" name="terms" required>
      <label for="terms">I agree to the Terms of Service</label>
    </div>
  </fieldset>
  
  <button type="submit">Create Account</button>
  <button type="reset">Clear Form</button>
</form>
```

**Key additions:**
- `<fieldset>` and `<legend>` group related inputs and label the group
- `pattern` attribute for client-side validation
- `aria-describedby` links inputs to helper text
- `type="range"` with `<output>` for interactive controls
- Checkboxes with associated labels
- Both submit and reset buttons

### Step 3: Radio Buttons and Select Lists

```html
<form>
  <fieldset>
    <legend>Shipping Method</legend>
    
    <div>
      <input id="standard" type="radio" name="shipping" value="standard" checked>
      <label for="standard">Standard (5-7 business days)</label>
    </div>
    
    <div>
      <input id="express" type="radio" name="shipping" value="express">
      <label for="express">Express (2-3 business days) — $5 extra</label>
    </div>
    
    <div>
      <input id="overnight" type="radio" name="shipping" value="overnight">
      <label for="overnight">Overnight (1 business day) — $15 extra</label>
    </div>
  </fieldset>
  
  <fieldset>
    <legend>Country</legend>
    
    <label for="country">Select your country:</label>
    <select id="country" name="country" required>
      <option value="">-- Choose one --</option>
      <option value="us">United States</option>
      <option value="ca">Canada</option>
      <option value="mx">Mexico</option>
      <option value="other">Other</option>
    </select>
  </fieldset>
  
  <button type="submit">Continue</button>
</form>
```

**Key principles:**
- Radio buttons with the same `name` form a group (only one can be selected)
- Each radio button and label pair has a unique `id`
- `<select>` has a `<label>` associated via `for` attribute
- First `<option>` is a placeholder ("Choose one")

### Step 4: Validation and Error Messaging

```html
<form>
  <div class="form-group">
    <label for="password">Password</label>
    <input 
      id="password"
      type="password"
      name="password"
      minlength="8"
      pattern="^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])"
      placeholder="At least 8 characters"
      required
      aria-describedby="password-requirements"
    >
    <ul id="password-requirements" class="requirements">
      <li>At least 8 characters</li>
      <li>At least one uppercase letter</li>
      <li>At least one number</li>
      <li>At least one special character (!@#$%^&*)</li>
    </ul>
  </div>
  
  <button type="submit">Create Password</button>
</form>

<style>
  /* Style invalid fields */
  input:invalid {
    border-color: #dc2626;
    background-color: #fee2e2;
  }
  
  input:valid {
    border-color: #16a34a;
  }
  
  /* Show/hide requirements based on validity */
  input:focus ~ #password-requirements {
    display: block;
  }
</style>
```

### Step 5: Button vs. Link Semantics

Buttons perform actions. Links navigate.

```html
<!-- ✓ CORRECT: Button for form submission -->
<form>
  <input type="text" name="search" placeholder="Search...">
  <button type="submit">Search</button>
</form>

<!-- ✗ WRONG: Using a link to submit a form -->
<form>
  <input type="text" name="search" placeholder="Search...">
  <a href="#" onclick="submitForm()">Search</a>  <!-- Don't do this -->
</form>

<!-- ✓ CORRECT: Link for navigation -->
<a href="/about">Learn More</a>

<!-- ✗ WRONG: Using a button to navigate -->
<button onclick="window.location.href='/about'">Learn More</button>  <!-- Don't do this -->

<!-- ✓ CORRECT: Different button types -->
<button type="submit">Save</button>      <!-- Submits the form -->
<button type="reset">Clear</button>      <!-- Resets all inputs -->
<button type="button">Cancel</button>    <!-- Custom action (requires JS) -->
```

## Use It

Modern form frameworks validate this for you:

- **HTML5 Constraint API:** Built-in browser validation
- **React Hook Form:** Manages form state and validation
- **Formik:** Complex form logic with error handling
- **WPForms / Gravity Forms:** Drag-and-drop form builders

But the foundation is always HTML semantics. No framework can replace proper labels and input types.

## Ship It

Create a **reusable form component template** demonstrating:
- Proper label association
- Input type selection
- Fieldset organization
- Validation patterns
- Error messaging

## Exercises

1. **Accessibility Audit:** Open a website with a form. Use a screen reader (NVDA on Windows, VoiceOver on Mac) to navigate the form without looking at the screen. Can you understand what each field does? Is labeling clear?

2. **Build a Reservation Form:** Create an HTML form for booking a hotel stay with:
   - Name, email, phone (proper input types)
   - Check-in and check-out dates (date inputs)
   - Number of guests (number input, range 1-10)
   - Room preference (radio buttons)
   - Add-on services (checkboxes)
   - Terms agreement checkbox
   - Submit and reset buttons
   
   Validate it with the W3C HTML Validator.

3. **Test Input Types on Mobile:** Open your form on a mobile device. Notice how the keyboard changes for email, tel, and date inputs. This is input types in action.

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|----------------------|
| **Label** | "Just text next to the input" | A semantic element associated with an input via `for` attribute; critical for screen readers and click targets |
| **Placeholder** | "A label replacement" | Temporary hint text that disappears when user types; NOT a label |
| **Fieldset** | "Optional for grouping" | A semantic container that groups logically related form fields and improves accessibility |
| **Pattern** | "Just for decoration" | A regular expression that validates user input format (email, phone, etc.) |
| **Input Type** | "Cosmetic differences" | Fundamentally different input modes that affect mobile keyboards, browser validation, and UX |
| **Button vs. Link** | "Same thing with different styling" | Buttons trigger actions; links navigate. Semantically and functionally different |

## Further Reading

- [MDN: HTML Forms](https://developer.mozilla.org/en-US/docs/Learn/Forms) — Comprehensive forms guide
- [WebAIM: Creating Accessible Forms](https://webaim.org/articles/form_labels/) — Detailed accessibility focus
- [Web.dev: Sign-in Form Best Practices](https://web.dev/sign-in-form-best-practices/) — Google's form UX research
- [HTML5 Input Types](https://www.html5rocks.com/en/tutorials/forms/html5forms/) — Deep dive into modern input types
- [Form Validation](https://www.smashingmagazine.com/2022/09/inline-validation-web-forms-ux/) — Validation patterns and UX
