# Semantic HTML5 Elements

> Semantic HTML replaces the guessing game of `<div>` soup with tags that tell the true story of your content.

**Type:** Learn
**Languages:** HTML
**Prerequisites:** 01-document-structure-metadata
**Time:** ~50 minutes

## Learning Objectives

- Replace generic divs with meaningful semantic elements
- Structure content using proper heading hierarchies
- Distinguish between physical and logical text formatting
- Group content effectively with semantic containers

## The Problem

Two developers build a page about a blog post. One uses all `<div>` tags and relies on CSS classes to suggest meaning. The other uses `<article>`, `<section>`, `<header>`, and `<footer>` tags. 

From a browser perspective:
- Screen reader users can't navigate the structure because there's no inherent meaning
- Search engines can't distinguish between navigation, main content, and sidebar
- CSS-dependent styling breaks when someone disables CSS (rare, but it happens)
- Future developers (or you, six months later) can't quickly scan the HTML and understand the page structure

Semantic HTML is self-documenting. It says: "This is an article," not "This is a div with class='post'."

## The Concept

HTML provides a set of tags that describe **what the content is**, not just how it looks:

```
Generic (Non-Semantic)         Semantic (Meaningful)
────────────────────          ─────────────────────
<div>                          <header>
<div>                          <nav>
<div>                          <main>
<div>                          <article>
<div>                          <section>
```

### Semantic Layout Landmarks

```
┌─────────────────────────────────────────┐
│           <header>                      │  Page header (logo, title, intro)
├─────────────────────────────────────────┤
│ <nav>          │                        │  Navigation menu on left
│                │      <main>            │  Primary content
│                │                        │  (contains <article>)
│                │                        │
├─────────────────────────────────────────┤
│           <footer>                      │  Page footer (copyright, links)
└─────────────────────────────────────────┘
```

### Content Hierarchy with Headings

Search engines and screen readers build a "document outline" from heading levels. Your outline should be logical:

```
✓ GOOD HIERARCHY              ✗ BAD HIERARCHY
─────────────────            ──────────────
<h1>Main Topic               <h1>Page Title
  <h2>Subtopic               <h3>Subtopic   (skips h2!)
    <h3>Detail               <h2>Another
      <h4>Minor              <h1>Abrupt jump
```

### Text-Level Semantics

| Physical Tag | Logical Tag | When to Use |
|--------------|-------------|------------|
| `<b>` | `<strong>` | Keywords, important phrases. Implies urgency/importance, not just bold appearance |
| `<i>` | `<em>` | Emphasis, stress, or alternative voice. Implies emotional weight |
| `<u>` | `<ins>` or `<mark>` | `<ins>`: inserted/new text; `<mark>`: highlighted/relevant text |
| — | `<cite>` | Attribution or reference to another work |
| — | `<code>` | Computer code or technical terms |
| — | `<samp>` | Sample output from a program |
| — | `<kbd>` | User input (keyboard shortcuts, menu paths) |

## Build It

### Step 1: Replace Divs with Semantic Layout Tags

Before:
```html
<div class="page">
  <div class="header">
    <h1>My Blog</h1>
  </div>
  <div class="nav">
    <a href="/">Home</a>
    <a href="/about">About</a>
  </div>
  <div class="content">
    <div class="post">
      <h2>My First Post</h2>
      <p>Content goes here...</p>
    </div>
  </div>
  <div class="footer">
    <p>&copy; 2024 My Blog</p>
  </div>
</div>
```

After:
```html
<html>
  <body>
    <header>
      <h1>My Blog</h1>
    </header>
    <nav>
      <a href="/">Home</a>
      <a href="/about">About</a>
    </nav>
    <main>
      <article>
        <h2>My First Post</h2>
        <p>Content goes here...</p>
      </article>
    </main>
    <footer>
      <p>&copy; 2024 My Blog</p>
    </footer>
  </body>
</html>
```

### Step 2: Create a Proper Content Hierarchy

Build a logical outline using heading levels:

```html
<main>
  <article>
    <h1>Understanding Web Accessibility</h1>
    <!-- h1 is the article's main title -->
    
    <p>An introduction to making the web inclusive...</p>
    
    <section>
      <h2>What is Accessibility?</h2>
      <!-- h2: first major section -->
      
      <p>Accessibility means designing for all users...</p>
      
      <h3>Why It Matters</h3>
      <!-- h3: subsection of "What is Accessibility?" -->
      
      <p>Approximately 1 in 4 adults in the US have some type of disability...</p>
    </section>
    
    <section>
      <h2>Core Principles</h2>
      <!-- h2: second major section, same level as first -->
      
      <h3>Perceivable</h3>
      <!-- h3: subsection of "Core Principles" -->
      <p>Users must be able to perceive the information...</p>
      
      <h3>Operable</h3>
      <p>The interface must be operable by keyboard...</p>
    </section>
  </article>
</main>
```

### Step 3: Use Text-Level Semantic Tags Correctly

```html
<article>
  <h1>Coffee: The Science Behind Your Morning Cup</h1>
  
  <p>
    <strong>Caffeine</strong> is the world's most consumed psychoactive drug.
    When you drink coffee, the caffeine enters your bloodstream and travels to your brain.
  </p>
  
  <p>
    There's a common myth that <strong>cold brew coffee</strong> has 
    <em>significantly</em> less caffeine than hot coffee. While cold brew 
    <em>may</em> contain slightly less, the difference is negligible.
  </p>
  
  <p>
    Here's how to brew the perfect cup:
  </p>
  
  <ol>
    <li>Grind your beans to medium-coarse (<code>consistency: granulated sugar</code>)</li>
    <li>Heat water to <kbd>195–205°F (90–96°C)</kbd></li>
    <li>Brew for 4–6 minutes</li>
  </ol>
  
  <p>
    According to <cite>The Coffee Chronicles</cite>, this method extracts 
    the optimal balance of flavor and caffeine.
  </p>
  
  <p>
    <mark>Pro tip:</mark> Drink your coffee <em>before</em> 3 PM to avoid 
    disrupting your sleep cycle. Caffeine's half-life is 5–6 hours.
  </p>
</article>
```

### Step 4: Group Content with Semantic Elements

Use `<figure>` and `<figcaption>` for images, charts, or code examples:

```html
<article>
  <h2>The Caffeine Response Timeline</h2>
  
  <figure>
    <img src="caffeine-timeline.png" alt="Timeline showing caffeine absorption">
    <figcaption>
      Caffeine reaches peak levels in your bloodstream 30–60 minutes after consumption.
      After <time datetime="PT5H">5 hours</time>, about 50% of the caffeine has been metabolized.
    </figcaption>
  </figure>
  
  <p>Understanding this timeline helps you time your coffee breaks strategically.</p>
</article>
```

Use `<blockquote>` for quoted content:

```html
<article>
  <h2>What Experts Say</h2>
  
  <blockquote cite="https://example.com/coffee-science">
    <p>Coffee doesn't just wake you up—it also improves focus and can even reduce the risk of certain diseases.</p>
    <footer>— Dr. Jane Smith, <cite>Coffee Science Quarterly</cite></footer>
  </blockquote>
</article>
```

### Step 5: Complex Layout with Multiple Sections

```html
<body>
  <header>
    <h1>Tech News Daily</h1>
    <p>Your source for technology news and analysis</p>
  </header>
  
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/news">News</a></li>
      <li><a href="/analysis">Analysis</a></li>
    </ul>
  </nav>
  
  <main>
    <article>
      <h1>AI Reaches New Milestone</h1>
      <p>Posted on <time datetime="2024-05-13">May 13, 2024</time></p>
      
      <p>Content of the main article...</p>
      
      <section>
        <h2>Background</h2>
        <p>Historical context...</p>
      </section>
      
      <section>
        <h2>Impact</h2>
        <p>What this means for the industry...</p>
      </section>
    </article>
    
    <aside>
      <h3>Related Articles</h3>
      <ul>
        <li><a href="/article1">Article 1</a></li>
        <li><a href="/article2">Article 2</a></li>
      </ul>
    </aside>
  </main>
  
  <footer>
    <p>&copy; 2024 Tech News Daily</p>
  </footer>
</body>
```

## Use It

When you inspect a well-built website's HTML (like the New York Times, MDN, or Wikipedia), you'll see:

- `<header>` / `<footer>` for page structure
- `<article>` for self-contained content
- `<section>` to organize major content areas
- `<aside>` for tangential content (sidebars, related links)
- `<nav>` for navigation regions
- Proper heading hierarchy (no skipped levels)
- Semantic text tags (`<strong>`, `<em>`, `<code>`) instead of generic `<b>` and `<i>`

## Ship It

Create an **HTML semantic template** for a blog post that demonstrates all these elements working together.

## Exercises

1. **Audit a Page:** Pick any website you use regularly. Open DevTools and inspect the HTML. Count how many `<div>` tags are used vs. semantic tags. What do you notice?

2. **Convert to Semantic HTML:** Take this non-semantic example and rewrite it using proper semantic tags:
   ```html
   <div id="page">
     <div id="header"><span id="title">Blog</span></div>
     <div id="menu"><a href="/">Home</a></div>
     <div id="content"><div class="post"><span class="title">First Post</span></div></div>
   </div>
   ```

3. **Test Your Heading Outline:** Create an HTML document and use the [HTML5 Outline Generator](https://html5.validator.nu/) to view the heading structure. Ensure it reads logically when headings are extracted in order.

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|----------------------|
| **Semantic HTML** | "Just a best practice; styling works fine without it" | HTML that conveys meaning to browsers and assistive technology; affects accessibility, SEO, and maintainability |
| **Article vs. Section** | "Section is for smaller sections, article for big content" | `<article>` is self-contained and reusable; `<section>` groups related content. An article can contain sections |
| **Heading Hierarchy** | "Use h2 for subtitles, h3 for details—levels don't matter" | Each heading level defines document structure; skipping levels confuses screen readers and SEO |
| **Strong vs. Bold** | "They look the same so they're interchangeable" | `<strong>` signals importance; `<b>` is just visual. Assistive tech announces strong, ignores bold |
| **Em vs. Italic** | "Same thing, different names" | `<em>` is semantic emphasis; `<i>` is just presentation. Screen readers may pause for `<em>` |

## Further Reading

- [MDN: Semantic HTML](https://developer.mozilla.org/en-US/docs/Glossary/Semantics) — Core concepts with examples
- [HTML5 Doctor: Elements](http://html5doctor.com/) — Deep dives into semantic elements
- [The Accessibility Tree](https://www.smashingmagazine.com/2015/10/structured-content-for-better-accessibility/) — How screen readers parse semantic HTML
- [HTML Outliner](https://html5.validator.nu/) — Tool to verify your heading structure
- [Web.dev: Page Structure](https://web.dev/learn/html/structure/) — Google's guide to semantic layout
