# Accessibility (A11y) Fundamentals

> Accessibility isn't an edge case—it's a core part of web development. 1 in 4 adults have some type of disability. Build for everyone.

**Type:** Learn
**Languages:** HTML
**Prerequisites:** All prior lessons in this phase
**Time:** ~65 minutes

## Learning Objectives

- Implement alt text and descriptions for images
- Use ARIA roles and attributes when semantic HTML isn't enough
- Manage keyboard focus and tab order
- Ensure color contrast and text readability
- Test accessibility with real tools and real users

## The Problem

You build a beautiful website. You test it in Chrome, Firefox, Safari. It works perfectly. But you've missed 15% of internet users—those using assistive technology:

- Screen reader users (blind, low vision)
- Keyboard-only users (mobility impairments)
- Users with cognitive or learning disabilities
- Users with color blindness
- Users on slow connections or old devices

Inaccessible websites aren't just unfair—they're often illegal. The Americans with Disabilities Act (ADA) applies to websites. The EU has the Web Accessibility Directive. Lawsuits have forced companies to pay millions.

But beyond legality, it's the right thing to do. The web's power is that it's universal. Accessibility makes that possible.

## The Concept

Web accessibility is based on four principles (POUR):

```
┌──────────────────────────────────────────────────────────┐
│ PERCEIVABLE                                              │
│ ├─ Text alternatives for images (alt text)              │
│ ├─ Captions for video/audio                             │
│ ├─ Color not the only way to convey information         │
│ └─ Enough contrast for visibility (4.5:1 for text)      │
├──────────────────────────────────────────────────────────┤
│ OPERABLE                                                 │
│ ├─ Fully keyboard accessible                            │
│ ├─ No keyboard traps (can always tab out)               │
│ ├─ Enough time to read and interact                     │
│ └─ No content that causes seizures                      │
├──────────────────────────────────────────────────────────┤
│ UNDERSTANDABLE                                           │
│ ├─ Clear, simple language                              │
│ ├─ Predictable navigation and behavior                 │
│ ├─ Clear labeling and instructions                     │
│ └─ Input validation with error messages                │
├──────────────────────────────────────────────────────────┤
│ ROBUST                                                   │
│ ├─ Valid HTML                                           │
│ ├─ Semantic structure                                  │
│ ├─ ARIA used correctly (not as a band-aid)            │
│ └─ Works with assistive technology                     │
└──────────────────────────────────────────────────────────┘
```

## Build It

### Step 1: Alt Text That Actually Works

**Bad alt text:**
```html
<!-- ✗ No alt text -->
<img src="sunset.jpg">

<!-- ✗ Redundant -->
<img src="sunset.jpg" alt="Image of sunset">

<!-- ✗ Too long, not descriptive -->
<img src="sunset.jpg" alt="The sun is setting in the distance over a beautiful body of water with some clouds">
```

**Good alt text:**
```html
<!-- ✓ Concise, descriptive -->
<img src="sunset.jpg" alt="Sun setting over the ocean with pink clouds">

<!-- ✓ For complex images, use description -->
<figure>
  <img src="sales-chart.png" alt="Sales by region chart">
  <figcaption>
    North America led sales in Q1 with $2.3M, followed by Europe at $1.8M 
    and Asia at $1.2M. See the <a href="#data">data table</a> for details.
  </figcaption>
</figure>

<!-- ✓ For decorative images, use empty alt -->
<img src="decorative-line.svg" alt="">

<!-- ✓ For linked images, describe the destination -->
<a href="/products">
  <img src="featured-product.jpg" alt="Buy the XL Pro Bundle - save 30%">
</a>

<!-- ✓ For data-driven images, provide text alternative -->
<figure>
  <img src="infographic.png" alt="Internet usage statistics 2024">
  <div class="text-version">
    <h3>Internet Usage Statistics</h3>
    <ul>
      <li>Global users: 5.4 billion (67% of population)</li>
      <li>Mobile users: 7.1 billion (88% of internet users)</li>
      <li>Average daily usage: 4.8 hours</li>
    </ul>
  </div>
</figure>
```

**Alt text checklist:**
- ✓ Meaningful and concise (usually under 125 characters)
- ✓ Describes purpose, not appearance ("chart showing sales" not "blue bar chart")
- ✓ Doesn't start with "image of..." (screen readers already announce it's an image)
- ✓ Decorative images use empty `alt=""` (not omitted)
- ✓ For complex images, use surrounding text or `<figcaption>`

### Step 2: Semantic HTML as Accessibility Foundation

**Bad accessibility (relying on ARIA):**
```html
<div role="button" onclick="doSomething()">
  Click Me
</div>
<div role="navigation">
  <a href="/">Home</a>
  <a href="/about">About</a>
</div>
```

**Good accessibility (semantic HTML):**
```html
<button onclick="doSomething()">
  Click Me
</button>
<nav>
  <a href="/">Home</a>
  <a href="/about">About</a>
</nav>
```

*Rule of ARIA: First, use semantic HTML. Second, use ARIA only to enhance or clarify.*

### Step 3: Keyboard Navigation

```html
<!-- ✓ GOOD: Semantic elements are keyboard accessible by default -->
<button>Submit</button>
<a href="/page">Link</a>
<input type="text">

<!-- ✗ BAD: Custom interactive elements aren't keyboard accessible -->
<div onclick="submit()">Submit</div>

<!-- ✓ GOOD: If you must use div, add keyboard support -->
<div 
  role="button"
  tabindex="0"
  onclick="submit()"
  onkeypress="if(event.key==='Enter') submit()"
>
  Submit
</div>

<!-- ✓ GOOD: Control tab order explicitly -->
<header>
  <button tabindex="1">Skip to Main</button>
  <nav>
    <a href="/">Home</a>           <!-- tabindex 2 -->
    <a href="/about">About</a>     <!-- tabindex 3 -->
  </nav>
</header>

<main tabindex="1">
  <!-- Main content: tabindex 4, 5, 6, etc. -->
</main>

<!-- ✓ GOOD: Manage focus programmatically -->
<dialog id="modal">
  <h2>Confirm Action</h2>
  <p>Are you sure?</p>
  <button id="confirm">Yes</button>
  <button id="cancel">No</button>
</dialog>

<script>
  const modal = document.getElementById('modal');
  
  modal.addEventListener('showModal', () => {
    // Move focus into the modal when it opens
    document.getElementById('confirm').focus();
  });
  
  modal.addEventListener('close', () => {
    // Restore focus when modal closes
    triggerButton.focus();
  });
</script>
```

### Step 4: Color Contrast and Readability

```html
<!-- ✗ FAIL: 1.5:1 contrast (hard to read) -->
<p style="color: #999999; background-color: #f0f0f0;">
  Light gray on light background
</p>

<!-- ✓ PASS: 7:1 contrast (WCAG AAA, best) -->
<p style="color: #000000; background-color: #ffffff;">
  Black on white
</p>

<!-- ✓ PASS: 4.5:1 contrast (WCAG AA minimum for regular text) -->
<p style="color: #595959; background-color: #ffffff;">
  Dark gray on white
</p>

<!-- ✓ GOOD: Use semantic tags for structure, not styling -->
<p>
  <strong>Important:</strong> Use colors alongside other indicators.
</p>

<!-- ✗ BAD: Color alone conveys meaning -->
<form>
  <input type="text" style="border: 2px solid red;">
  <!-- Red indicates error, but what if user is colorblind? -->
</form>

<!-- ✓ GOOD: Color + text/icons convey meaning -->
<form>
  <div class="form-group error">
    <input 
      type="text" 
      aria-invalid="true"
      aria-describedby="email-error"
    >
    <span id="email-error" class="error-message">
      ⚠️ Invalid email address
    </span>
  </div>
</form>
```

### Step 5: ARIA for Enhanced Semantics

Use ARIA to clarify or supplement HTML:

```html
<!-- ✓ GOOD: Button that toggles a menu -->
<button 
  aria-haspopup="menu"
  aria-controls="user-menu"
  aria-expanded="false"
  id="menu-button"
>
  User Menu
</button>

<ul id="user-menu" role="menu">
  <li><a href="/profile">Profile</a></li>
  <li><a href="/settings">Settings</a></li>
  <li><a href="/logout">Logout</a></li>
</ul>

<script>
  const button = document.getElementById('menu-button');
  const menu = document.getElementById('user-menu');
  
  button.addEventListener('click', () => {
    const isOpen = button.getAttribute('aria-expanded') === 'true';
    button.setAttribute('aria-expanded', !isOpen);
    menu.hidden = isOpen;
  });
</script>

<!-- ✓ GOOD: Live region for dynamic updates -->
<div aria-live="polite" aria-atomic="true" id="notifications">
  <!-- Status messages will be announced as they appear -->
</div>

<button onclick="addNotification('Order confirmed!')">
  Buy Now
</button>

<script>
  function addNotification(message) {
    const notif = document.getElementById('notifications');
    notif.textContent = message;
    // Screen reader announces: "Order confirmed!"
  }
</script>

<!-- ✓ GOOD: Describe complex widgets -->
<div class="slider" role="slider" aria-label="Volume">
  <input 
    type="range" 
    min="0" 
    max="100" 
    aria-valuemin="0"
    aria-valuemax="100"
    aria-valuenow="50"
    aria-label="Volume slider"
  >
</div>

<!-- ✗ BAD: Overusing ARIA (site with all divs and ARIA) -->
<!-- Don't do this. Use semantic HTML first. -->
```

### Step 6: Complete Accessible Page

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Accessible Blog Post</title>
  <style>
    body {
      font-size: 16px;
      line-height: 1.6;
      color: #333;
      background-color: #fff;
    }
    
    a {
      color: #0066cc;
    }
    
    a:focus {
      outline: 3px solid #ffcc00;
      outline-offset: 2px;
    }
    
    button, input {
      font-size: 16px;
    }
    
    .skip-link {
      position: absolute;
      top: -40px;
      left: 0;
      background: #000;
      color: #fff;
      padding: 8px;
      text-decoration: none;
    }
    
    .skip-link:focus {
      top: 0;
    }
  </style>
</head>
<body>
  <!-- Skip to main content link for keyboard users -->
  <a href="#main" class="skip-link">Skip to main content</a>
  
  <header>
    <h1>My Accessible Blog</h1>
    <p>Thoughts on web development and accessibility</p>
  </header>
  
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/posts">Posts</a></li>
      <li><a href="/about">About</a></li>
      <li><a href="/contact">Contact</a></li>
    </ul>
  </nav>
  
  <main id="main">
    <article>
      <h1>Why Accessibility Matters</h1>
      
      <div class="meta">
        <time datetime="2024-05-13">May 13, 2024</time>
        <p>Reading time: ~8 minutes</p>
      </div>
      
      <figure>
        <img 
          src="accessibility-concept.png" 
          alt="Diverse group of people using different devices and assistive technologies"
        >
        <figcaption>
          Accessibility is designing for a diverse range of abilities and devices.
        </figcaption>
      </figure>
      
      <p>
        When we talk about web accessibility, we often think of screen readers
        and keyboard navigation. But accessibility is much broader...
      </p>
      
      <h2>The Four Principles</h2>
      
      <p>
        Web Content Accessibility Guidelines (WCAG) are built on four principles:
      </p>
      
      <ol>
        <li><strong>Perceivable:</strong> Users must be able to see, hear, or perceive the content</li>
        <li><strong>Operable:</strong> Users must be able to navigate using any input method</li>
        <li><strong>Understandable:</strong> Users must understand the content and how to use it</li>
        <li><strong>Robust:</strong> Content must work with assistive technology</li>
      </ol>
    </article>
    
    <aside>
      <h3>Related Resources</h3>
      <ul>
        <li><a href="https://www.w3.org/WAI/">W3C WAI</a></li>
        <li><a href="https://www.wcag.com/">WCAG Guidelines</a></li>
        <li><a href="https://webaim.org/">WebAIM</a></li>
      </ul>
    </aside>
  </main>
  
  <footer>
    <p>&copy; 2024 My Blog. Built with accessibility in mind.</p>
  </footer>
</body>
</html>
```

## Use It

Modern tools help enforce accessibility:

- **axe DevTools:** Browser extension that flags accessibility issues
- **WAVE:** Browser extension for visual accessibility feedback
- **Lighthouse:** Built into Chrome DevTools, audits accessibility (and performance)
- **NVDA / JAWS:** Screen readers for testing
- **Color Contrast Analyzer:** Tool to check color contrast ratios

## Ship It

Create an **accessibility checklist** for all future projects:

- [ ] All images have meaningful alt text
- [ ] Heading hierarchy is logical (no skipped levels)
- [ ] All interactive elements are keyboard accessible
- [ ] Color contrast is at least 4.5:1 for text
- [ ] Form inputs have associated labels
- [ ] Video has captions
- [ ] Focus is visible and managed
- [ ] Page passes Lighthouse accessibility audit (90+)
- [ ] Tested with screen reader (NVDA / VoiceOver)

## Exercises

1. **Alt Text Audit:**
   - Visit a website (any popular site)
   - Right-click images and inspect alt text
   - Is the alt text meaningful? Concise?
   - Are decorative images using empty alt?
   - Document improvements that could be made

2. **Screen Reader Testing:**
   - Download NVDA (Windows) or use VoiceOver (Mac)
   - Navigate your favorite website with just keyboard and screen reader
   - Can you understand the structure?
   - Can you use forms without seeing?
   - Document accessibility issues you discover

3. **Build an Accessible Form:**
   - Create an HTML form for a product purchase
   - Include proper labels, hint text, error messages
   - Ensure 4.5:1 color contrast
   - Test with Lighthouse audit
   - Achieve 90+ accessibility score

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|----------------------|
| **A11y** | "Just for people who are blind" | Numeronym for Accessibility (a + 11 letters + y); benefits everyone (mobility, temporary injuries, elderly, etc.) |
| **Alt Text** | "Just image descriptions" | Critical accessibility feature; also used for SEO, slow connections, broken images |
| **ARIA** | "The solution to inaccessible HTML" | Band-aid for HTML that doesn't use semantics; should never replace semantic HTML |
| **Keyboard Accessible** | "Only for power users" | Fundamental requirement; affects users with mobility impairments, arthritis, or any input device |
| **Contrast Ratio** | "Doesn't matter if text is large" | Even large text needs sufficient contrast for people with low vision or in bright environments |
| **Focus Management** | "Only relevant for keyboard users" | Critical for screen reader users to understand what element they're currently on |

## Further Reading

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/) — Official accessibility standard
- [WebAIM Articles](https://webaim.org/articles/) — In-depth accessibility topics
- [The A11y Project](https://www.a11yproject.com/) — Community-driven accessibility resources
- [Microsoft Inclusive Design Toolkit](https://download.microsoft.com/download/B/0/D/B0D4BF87-09CE-4417-8F28-D60703D672ED/inclusive_toolkit_manual_final.pdf) — Design thinking for accessibility
- [Screen Reader Testing Guide](https://www.smashingmagazine.com/2018/12/voiceover-screen-reader-web-accessibility/) — How to test with VoiceOver
- [axe DevTools](https://www.deque.com/axe/devtools/) — Automated accessibility testing
