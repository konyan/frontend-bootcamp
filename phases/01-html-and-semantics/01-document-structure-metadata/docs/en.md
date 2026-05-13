# Document Structure & Metadata

> The head section is where the web page tells browsers and search engines who it is and how it should be perceived.

**Type:** Learn
**Languages:** HTML
**Prerequisites:** None
**Time:** ~45 minutes

## Learning Objectives

- Master the anatomy of an HTML document and the purpose of each section
- Implement SEO best practices through meta tags and Open Graph protocol
- Configure viewports and character encoding for responsive and correct display
- Set up favicons and PWA manifests for modern browsers

## The Problem

Two students build the same content, but one shows up in search results and displays beautifully when shared on social media. The other shows a generic preview. The difference? The head section. A poorly configured document head means:

- Search engines can't understand your page purpose
- Social shares look unprofessional and get fewer clicks
- Mobile browsers render your page incorrectly or too small
- Browser tabs lack visual identity (no favicon)
- PWA features don't work without proper manifest configuration

This lesson teaches you to use the head section strategically—not just as boilerplate, but as a control center for how your page presents itself to the world.

## The Concept

The HTML document has three main regions:

```
<!DOCTYPE html>
├── <html>
│   ├── <head>           [METADATA REGION]
│   │   ├── <meta>       [Instructions for browsers]
│   │   ├── <link>       [Resources: stylesheets, favicons]
│   │   ├── <title>      [Page identity]
│   │   └── <script>     [Preload JS]
│   │
│   └── <body>           [VISIBLE CONTENT]
│       ├── <header>     [Page header]
│       ├── <main>       [Primary content]
│       └── <footer>     [Page footer]
```

### Key Meta Tags

| Tag | Purpose | Example |
|-----|---------|---------|
| `charset` | Specifies character encoding | `<meta charset="UTF-8">` |
| `viewport` | Enables responsive design | `<meta name="viewport" content="width=device-width, initial-scale=1.0">` |
| `description` | SEO snippet shown in search results | `<meta name="description" content="...">` |
| `keywords` | Topic hints for search engines | `<meta name="keywords" content="...">` |
| `og:*` | Controls how page appears when shared | `<meta property="og:image" content="...">` |
| `twitter:*` | Twitter-specific sharing metadata | `<meta name="twitter:card" content="summary">` |

## Build It

### Step 1: Create a Minimal Valid HTML Document

Start with the bare essentials—UTF-8 encoding, responsive viewport, and a meaningful title:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My First Web Page</title>
  </head>
  <body>
    <h1>Hello, World!</h1>
  </body>
</html>
```

### Step 2: Add SEO Metadata

Define what your page is about for search engines:

```html
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>The Complete Guide to Web Semantics | Learn HTML</title>
  <meta name="description" content="Master semantic HTML, accessibility, and SEO best practices. Build meaningful, inclusive web pages from scratch.">
  <meta name="keywords" content="HTML5, semantics, accessibility, SEO, web standards">
  <meta name="author" content="Your Name">
</head>
```

### Step 3: Implement Open Graph Tags for Social Sharing

When your page is shared on Facebook, LinkedIn, or other platforms, these tags control the preview:

```html
<head>
  <!-- ... existing meta tags ... -->
  
  <!-- Open Graph for social sharing -->
  <meta property="og:title" content="The Complete Guide to Web Semantics">
  <meta property="og:description" content="Master semantic HTML, accessibility, and SEO best practices.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://example.com/guide">
  <meta property="og:image" content="https://example.com/images/og-image.png">
  <meta property="og:image:alt" content="Two developers reviewing semantic HTML code">
  <meta property="og:site_name" content="Web Fundamentals">
  <meta property="og:locale" content="en_US">
</head>
```

### Step 4: Add Twitter Card Metadata

Twitter has its own metadata system for rich previews:

```html
<head>
  <!-- ... existing meta tags ... -->
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="The Complete Guide to Web Semantics">
  <meta name="twitter:description" content="Master semantic HTML, accessibility, and SEO.">
  <meta name="twitter:image" content="https://example.com/images/twitter-image.png">
  <meta name="twitter:image:alt" content="Semantic HTML best practices">
  <meta name="twitter:creator" content="@yourhandle">
</head>
```

### Step 5: Configure Favicon and PWA Manifest

Make your page identifiable in browser tabs and PWA-ready:

```html
<head>
  <!-- ... existing meta tags ... -->
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/favicon.png" sizes="any">
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">
  
  <!-- PWA Manifest -->
  <link rel="manifest" href="/site.webmanifest">
  
  <!-- Theme Color for Mobile -->
  <meta name="theme-color" content="#2563eb">
</head>
```

### Step 6: Complete Document with Preloading

Optimize performance by hinting what resources the browser should preload:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <!-- Preload critical assets -->
    <link rel="preload" as="font" href="/fonts/inter.woff2" crossorigin>
    <link rel="preconnect" href="https://api.example.com">
    
    <!-- Character encoding (must be first) -->
    <meta charset="UTF-8">
    
    <!-- Viewport for responsive -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- Title -->
    <title>The Complete Guide to Web Semantics | Learn HTML</title>
    
    <!-- SEO -->
    <meta name="description" content="Master semantic HTML, accessibility, and SEO.">
    <meta name="keywords" content="HTML5, semantics, accessibility, SEO">
    
    <!-- Social Sharing -->
    <meta property="og:title" content="The Complete Guide to Web Semantics">
    <meta property="og:description" content="Master semantic HTML, accessibility, and SEO.">
    <meta property="og:image" content="https://example.com/og-image.png">
    <meta name="twitter:card" content="summary_large_image">
    
    <!-- Brand Identity -->
    <link rel="icon" type="image/png" href="/favicon.png">
    <link rel="manifest" href="/site.webmanifest">
    <meta name="theme-color" content="#2563eb">
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="/styles.css">
  </head>
  <body>
    <header>
      <h1>Web Fundamentals</h1>
    </header>
    <main>
      <article>
        <h2>The Complete Guide to Web Semantics</h2>
        <p>Learn how to build meaningful, accessible HTML documents...</p>
      </article>
    </main>
    <script src="/app.js"></script>
  </body>
</html>
```

## Use It

Modern frameworks (Next.js, React Helmet, Astro) abstract away manual head management. But understanding what's happening underneath makes you a better developer:

- **Next.js Head Component:** Uses `next/head` to inject metadata at build time
- **React Helmet:** A library that manages document head dynamically
- **Astro Meta Tags:** Provide file-based metadata configuration
- **Nuxt Meta:** Vue-based framework with built-in head management

The principle remains: your head section is a contract with browsers and crawlers about what your page is.

## Ship It

Create a reusable **HTML head template** that includes SEO, social sharing, and PWA configuration. This becomes your starting point for every new project.

## Exercises

1. **Validate Your Document:** Create an HTML file with the complete head section from Step 6. Use the [W3C HTML Validator](https://validator.w3.org/) to ensure it has zero errors.

2. **Preview Social Sharing:** Use the [Facebook Open Graph Debugger](https://developers.facebook.com/tools/debug/og/object/) or [Twitter Card Validator](https://cards-dev.twitter.com/validator) to test how your page would appear when shared.

3. **Compare Head Sections:** Visit three popular websites (news site, e-commerce, blog) and inspect their head sections using DevTools. Identify which meta tags they use and which they don't. What patterns do you notice?

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|----------------------|
| **Meta tag** | "Optional decoration for the page" | Instructions that tell browsers, search engines, and social platforms how to interpret your content |
| **Viewport** | "Only matters for mobile" | Critical configuration that tells the browser how to scale content for any device size |
| **Open Graph** | "Facebook-specific feature" | An open protocol used across platforms (LinkedIn, Slack, Discord, etc.) for rich link previews |
| **Charset** | "Just put UTF-8 and forget it" | The character encoding that determines how text bytes are interpreted; wrong choice can break international content |
| **Preload/Preconnect** | "Performance tricks" | Hints that tell the browser about upcoming dependencies, reducing time to first paint |

## Further Reading

- [MDN: The HTML Head](https://developer.mozilla.org/en-US/docs/Learn/HTML/Introduction_to_HTML/The_head_metadata_in_HTML) — Comprehensive guide to head elements
- [Open Graph Protocol](https://ogp.me/) — Official spec for social sharing metadata
- [Twitter Cards Documentation](https://developer.twitter.com/en/docs/twitter-for-websites/cards/guides/getting-started) — How Twitter displays rich previews
- [Web.dev: Web Vitals](https://web.dev/vitals/) — Performance metrics that head metadata helps optimize
- [PWA Manifest Spec](https://www.w3.org/TR/appmanifest/) — Deep dive into progressive web app configuration
