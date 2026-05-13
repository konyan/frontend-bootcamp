# Interactive & Multimedia Elements

> The web is richer than text. Learn to embed, optimize, and make images, video, and audio accessible to everyone.

**Type:** Learn
**Languages:** HTML
**Prerequisites:** 01-document-structure-metadata, 02-semantic-html5-elements
**Time:** ~60 minutes

## Learning Objectives

- Implement responsive images with `<picture>` and `srcset`
- Embed video and audio with proper fallback content
- Use `<iframe>` safely and accessibly
- Build accessible multimedia experiences
- Create progressive disclosure patterns with `<details>`

## The Problem

You visit a news site on your phone over 3G. The page loads a 4MB image optimized for desktop. It takes 30 seconds. Someone on a 5K display loads the same image intended for mobile—it looks blurry.

Meanwhile, a user with cognitive disabilities encounters a video without captions. An image without alt text means a screen reader user sees nothing. An iframe embeds a tracking service that profiles users across the web.

Multimedia on the web requires responsibility:
- **Performance:** Serve the right size image to the right device
- **Accessibility:** Provide captions, transcripts, and descriptions
- **Privacy:** Know what third-party iframes are doing
- **Compatibility:** Include fallbacks for unsupported formats

## The Concept

Multimedia elements come in layers:

```
Layer 1: Default Content (what browsers without support see)
Layer 2: Modern Elements (<video>, <audio>, <picture>)
Layer 3: Fallback Content (alternative formats)
Layer 4: Accessibility (captions, descriptions, aria-labels)

Example with <video>:
<video controls>
  <source src="movie.webm" type="video/webm">    ← Try this first
  <source src="movie.mp4" type="video/mp4">     ← Fallback format
  <track kind="captions" src="captions.vtt">    ← Captions file
  <p>Your browser doesn't support HTML5 video. 
     <a href="movie.mp4">Download instead</a>.</p> ← Last resort
</video>
```

### Image Optimization Strategy

```
          User's Device
                 ↓
    ┌──────────────────────┐
    │ Screen Width Check   │
    └──────────────────────┘
       ↓              ↓              ↓
    Mobile        Tablet        Desktop
    320px         768px          1920px
      ↓              ↓              ↓
  image-sm.jpg  image-md.jpg  image-lg.jpg
    100KB         250KB          800KB
```

Using `srcset`, the browser downloads ONLY the appropriate size.

### Format Support Matrix

| Format | Pros | Cons | Browser Support |
|--------|------|------|-----------------|
| **PNG** | Lossless, transparency | Large file size | Universal |
| **JPEG** | Compact, lossy | No transparency | Universal |
| **WebP** | 25% smaller than JPEG | No IE support, mobile mixed | Modern browsers |
| **AVIF** | 20% smaller than WebP | Limited support | Cutting edge |
| **GIF** | Animation, simple | Huge file sizes | Universal (use video instead) |
| **SVG** | Scalable, tiny | Not for photos | Universal |

## Build It

### Step 1: Simple Responsive Image with srcset

```html
<img 
  src="image-default.jpg"
  srcset="
    image-small.jpg 320w,
    image-medium.jpg 768w,
    image-large.jpg 1920w
  "
  alt="A beautiful sunset over the ocean"
  sizes="(max-width: 768px) 100vw, (max-width: 1920px) 50vw, 800px"
>
```

**How it works:**
1. Browser checks viewport width and pixel density
2. Browser matches viewport to a `sizes` breakpoint
3. Browser calculates needed width (e.g., `50vw` = 50% of viewport width)
4. Browser selects closest image from `srcset` that fits that width
5. Browser downloads only that image

### Step 2: Art Direction with `<picture>`

Sometimes you don't just resize—you need different compositions for different viewports:

```html
<!-- Portrait on mobile, landscape on desktop -->
<picture>
  <source 
    media="(max-width: 768px)" 
    srcset="team-portrait-small.jpg 320w, team-portrait-large.jpg 768w"
  >
  <source 
    media="(min-width: 769px)" 
    srcset="team-landscape-small.jpg 1024w, team-landscape-large.jpg 2048w"
  >
  <img src="team-landscape-large.jpg" alt="Our team of 12 engineers at the office">
</picture>
```

### Step 3: Modern Image Formats with Fallback

```html
<!-- Browser loads WebP on supported browsers, JPEG on older browsers -->
<picture>
  <source srcset="photo.webp" type="image/webp">
  <source srcset="photo.avif" type="image/avif">
  <img src="photo.jpg" alt="Mountain landscape">
</picture>
```

### Step 4: Embed Video with Captions and Fallback

```html
<video 
  width="640" 
  height="360" 
  controls 
  poster="thumbnail.jpg"
  aria-label="Introduction to Web Accessibility"
>
  <!-- Primary format: MP4 (compatible with most browsers) -->
  <source src="intro.mp4" type="video/mp4">
  
  <!-- Fallback: WebM for Firefox, smaller file size -->
  <source src="intro.webm" type="video/webm">
  
  <!-- Subtitles and captions -->
  <track kind="captions" src="captions.en.vtt" srclang="en" label="English">
  <track kind="captions" src="captions.es.vtt" srclang="es" label="Español">
  
  <!-- Fallback for ancient browsers -->
  <p>
    Your browser doesn't support HTML5 video. 
    <a href="intro.mp4">Download the video</a> instead.
  </p>
</video>
```

**Key attributes:**
- `controls`: Show play/pause, volume, fullscreen buttons
- `poster`: Image displayed before play
- `<track>`: Caption file (VTT format)
- `kind="captions"`: Includes dialogue and sound effects for deaf users
- `kind="subtitles"`: Just dialogue translation, no sound effects

### Step 5: Embed Audio with Transcript

```html
<audio controls aria-label="Episode 42: The Future of Web Standards">
  <source src="episode-42.mp3" type="audio/mpeg">
  <source src="episode-42.ogg" type="audio/ogg">
  <p>
    Your browser doesn't support HTML5 audio.
    <a href="episode-42.mp3">Download the episode</a>.
  </p>
</audio>

<!-- Always provide a transcript for accessibility -->
<details>
  <summary>Episode Transcript</summary>
  <p>
    <strong>Host:</strong> Welcome to Web Standards Weekly. I'm your host, and 
    today we're discussing the future of the platform...
  </p>
  <p>
    <strong>Guest:</strong> Thanks for having me. The key developments to watch...
  </p>
</details>
```

### Step 6: Responsive Embedded Content (iframe)

Iframes are tricky to make responsive. Use this technique:

```html
<div class="video-container">
  <iframe
    width="560"
    height="315"
    src="https://www.youtube.com/embed/dQw4w9WgXcQ"
    title="YouTube video player"
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
    allowfullscreen
  ></iframe>
</div>

<style>
  .video-container {
    position: relative;
    width: 100%;
    max-width: 560px;
    margin: 0 auto;
  }
  
  .video-container::before {
    content: '';
    display: block;
    padding-bottom: 56.25%; /* 16:9 aspect ratio */
  }
  
  .video-container iframe {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    border: none;
  }
</style>
```

### Step 7: Progressive Disclosure with `<details>`

```html
<details open>
  <summary>
    <strong>Course Requirements</strong>
  </summary>
  
  <div>
    <h3>Prerequisites</h3>
    <ul>
      <li>Basic HTML knowledge</li>
      <li>Familiarity with command line</li>
      <li>Text editor (VS Code recommended)</li>
    </ul>
    
    <h3>Hardware Requirements</h3>
    <ul>
      <li>Minimum 4GB RAM</li>
      <li>10GB free disk space</li>
      <li>Reliable internet connection</li>
    </ul>
  </div>
</details>

<details>
  <summary>FAQ</summary>
  
  <dl>
    <dt>Can I complete this on a Mac?</dt>
    <dd>Yes, all tools are cross-platform.</dd>
    
    <dt>How long does this take?</dt>
    <dd>Most students finish in 4-6 weeks, studying 5-10 hours per week.</dd>
  </dl>
</details>

<style>
  summary {
    cursor: pointer;
    user-select: none;
  }
  
  summary:hover {
    background-color: #f3f4f6;
  }
  
  details[open] summary {
    margin-bottom: 1rem;
  }
</style>
```

### Step 8: Accessible Figure with Caption

```html
<figure>
  <picture>
    <source media="(max-width: 600px)" srcset="chart-mobile.svg">
    <img src="chart-desktop.svg" alt="Bar chart showing user growth">
  </picture>
  <figcaption>
    <strong>Figure 1:</strong> User growth over 12 months.
    Blue bars represent mobile users (60%), red bars represent desktop (40%).
    See <a href="#data-table">data table</a> for exact values.
  </figcaption>
</figure>

<table id="data-table">
  <caption>User Growth Data</caption>
  <!-- table content -->
</table>
```

## Use It

Production frameworks handle this complexity:

- **Next.js Image:** Automatic optimization, lazy loading, srcset generation
- **Astro Image:** Build-time image processing
- **Cloudinary / Imgix:** Cloud-based image optimization services
- **Vimeo / YouTube:** Managed video hosting with player controls

But know what's happening underneath. These tools are wrappers around semantic HTML.

## Ship It

Create an **image optimization template** and a **video embed component** that demonstrate:
- Responsive images with srcset and sizes
- Picture element with format fallbacks
- Video with captions and transcript
- Accessible multimedia practices

## Exercises

1. **Image Optimization Audit:** 
   - Visit a news website
   - Right-click an image → "Inspect"
   - Check its `src`, `srcset`, and `sizes`
   - Open DevTools Network tab and note the actual file size downloaded
   - Open the same page on mobile and check if a different image is downloaded

2. **Create a Responsive Gallery:**
   Build an HTML gallery with:
   - At least 5 images
   - Responsive sizing using srcset
   - Different crops for mobile vs. desktop using `<picture>`
   - Descriptive alt text for each image
   - Captions using `<figcaption>`
   
   Test on mobile and desktop to confirm correct image size is loading.

3. **Add Captions to a Video:**
   - Find a video file (MP4 or WebM)
   - Create a VTT (WebVTT) caption file with timestamps
   - Embed the video with HTML5 `<video>` and `<track>` elements
   - Test in a browser to ensure captions display

## Key Terms

| Term | Common Misconception | What It Actually Means |
|------|---------------------|----------------------|
| **srcset** | "Just for retina displays" | A mechanism to load the right image size for any device and viewport |
| **sizes** | "Not really necessary" | Critical for telling the browser what size the image will be, enabling proper image selection |
| **Picture element** | "Only for art direction" | Enables conditional image loading based on media queries (viewport size, pixel density, formats) |
| **Poster** | "Cosmetic thumbnail" | The frame shown before video plays; important for UX and perceived performance |
| **Track element** | "Optional accessibility feature" | Fundamental for providing captions/subtitles and making multimedia accessible |
| **Details/Summary** | "Just for styling" | Semantic elements for progressive disclosure—accessible without JavaScript |

## Further Reading

- [MDN: Responsive Images](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images) — Complete guide with examples
- [Web.dev: Serve Responsive Images](https://web.dev/serve-responsive-images/) — Performance best practices
- [WebAIM: Multimedia](https://webaim.org/articles/multimedia/) — Accessibility guidelines for video, audio, images
- [VideoJS](https://videojs.com/) — Open-source video player with accessibility features
- [WebVTT Spec](https://www.w3.org/TR/webvtt/) — Subtitle and caption file format
- [Accessible Video Players](https://www.nvaccess.org/download/) — NVDA screen reader for testing
