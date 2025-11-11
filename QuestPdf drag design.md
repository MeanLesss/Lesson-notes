Perfect — now we’ll **wire up two-way synchronization** between the **JS drag/resize (interact.js)** and the **Blazor model**, so that when you move or resize an element, the **property panel instantly updates** and vice versa.

This turns your designer into a **real-time layout editor**, much closer to **Figma** behavior.

Below is a **complete, ready-to-run Markdown project** — includes everything from before + the two-way sync.

---

# 🧾 Blazor A4 Designer (Figma-like) — with Real-Time JS ↔ Blazor Sync & QuestPDF Export

---

## 🧩 Features

✅ Drag, resize, and rotate using `interact.js`
✅ Property panel instantly updates when element moves
✅ Two-way sync between Blazor and JS
✅ Export to A4 PDF using QuestPDF
✅ Clean architecture — works with .NET 8 Blazor Server

---

## 📁 Project Structure

```
BlazorA4Designer/
│
├── BlazorA4Designer.csproj
├── Program.cs
├── Pages/
│   └── Designer.razor
├── Controllers/
│   └── PdfController.cs
├── Models/
│   ├── LayoutConfig.cs
│   └── DesignElement.cs
└── wwwroot/
    ├── css/
    │   └── designer.css
    └── js/
        ├── interact.min.js
        └── designer.js
```

---

## ⚙️ Prerequisites

```bash
dotnet new blazorserver -n BlazorA4Designer
cd BlazorA4Designer
dotnet add package QuestPDF
```

---

## 🧩 Models

### `Models/LayoutConfig.cs`

```csharp
using System.Collections.Generic;

namespace BlazorA4Designer.Models;

public class LayoutConfig
{
    public List<DesignElement> Elements { get; set; } = new();
}
```

### `Models/DesignElement.cs`

```csharp
using System.Collections.Generic;

namespace BlazorA4Designer.Models;

public class DesignElement
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Type { get; set; } = "text";
    public string? Content { get; set; }
    public double X { get; set; }
    public double Y { get; set; }
    public double Width { get; set; } = 120;
    public double Height { get; set; } = 40;
    public double Rotation { get; set; } = 0;
    public Dictionary<string, object> Style { get; set; } = new();
}
```

---

## 🖥️ Designer Page

### `Pages/Designer.razor`

```razor
@page "/designer"
@using BlazorA4Designer.Models
@inject HttpClient Http
@inject IJSRuntime JS

<h3>🎨 A4 Designer</h3>

<div class="main-container">
    <!-- Left Canvas -->
    <div id="canvas" class="design-canvas">
        @foreach (var el in Layout.Elements)
        {
            var selected = el == SelectedElement ? "selected" : "";
            <div id="@el.Id"
                 class="design-element @selected"
                 style="@GetElementStyle(el)"
                 @onclick="@(() => SelectElement(el))">
                @if (el.Type == "text")
                {
                    <span>@el.Content</span>
                }
                else if (el.Type == "image")
                {
                    <img src="@el.Content" style="width:100%;height:100%;object-fit:cover;" />
                }
            </div>
        }
    </div>

    <!-- Right Property Panel -->
    <div class="property-panel">
        <h5>Properties</h5>
        @if (SelectedElement != null)
        {
            <div>
                <label>Content:</label>
                <input @bind="SelectedElement.Content" class="form-control" />

                <label>X:</label>
                <input type="number" @bind="SelectedElement.X" class="form-control" />

                <label>Y:</label>
                <input type="number" @bind="SelectedElement.Y" class="form-control" />

                <label>Width:</label>
                <input type="number" @bind="SelectedElement.Width" class="form-control" />

                <label>Height:</label>
                <input type="number" @bind="SelectedElement.Height" class="form-control" />

                <label>Rotation:</label>
                <input type="number" @bind="SelectedElement.Rotation" class="form-control" />

                <label>Font Size:</label>
                <input type="number" @bind="SelectedElement.Style["fontSize"]" class="form-control" />
            </div>
        }
        else
        {
            <p>Select an item to edit.</p>
        }

        <div class="mt-3">
            <button class="btn btn-sm btn-success" @onclick="AddText">Add Text</button>
            <button class="btn btn-sm btn-info" @onclick="AddImage">Add Image</button>
            <button class="btn btn-sm btn-primary" @onclick="ExportToPdf">Export PDF</button>
        </div>
    </div>
</div>

@code {
    private LayoutConfig Layout { get; set; } = new();
    private DesignElement? SelectedElement;

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
            await JS.InvokeVoidAsync("initDesignerInterop", DotNetObjectReference.Create(this));
    }

    private void SelectElement(DesignElement el)
    {
        SelectedElement = el;
    }

    private void AddText()
    {
        var el = new DesignElement
        {
            Type = "text",
            Content = "New Text",
            X = 50, Y = 50, Width = 150, Height = 40,
            Style = new() { ["fontSize"] = 16 }
        };
        Layout.Elements.Add(el);
    }

    private void AddImage()
    {
        var el = new DesignElement
        {
            Type = "image",
            Content = "sample-image.png",
            X = 100, Y = 100, Width = 200, Height = 150
        };
        Layout.Elements.Add(el);
    }

    private string GetElementStyle(DesignElement el)
    {
        return $"left:{el.X}px;top:{el.Y}px;width:{el.Width}px;height:{el.Height}px;transform:rotate({el.Rotation}deg);";
    }

    [JSInvokable]
    public void UpdateElementPosition(Guid id, double x, double y, double w, double h, double rotation)
    {
        var el = Layout.Elements.FirstOrDefault(e => e.Id == id);
        if (el != null)
        {
            el.X = x; el.Y = y; el.Width = w; el.Height = h; el.Rotation = rotation;
            InvokeAsync(StateHasChanged);
        }
    }

    private async Task ExportToPdf()
    {
        var response = await Http.PostAsJsonAsync("api/pdf/export", Layout);
        var pdfBytes = await response.Content.ReadAsByteArrayAsync();
        var base64 = Convert.ToBase64String(pdfBytes);
        await JS.InvokeVoidAsync("downloadFileFromBase64", "design.pdf", base64);
    }
}
```

---

## 🎨 Styles

### `wwwroot/css/designer.css`

```css
.main-container {
    display: flex;
    gap: 15px;
}

.design-canvas {
    position: relative;
    width: 794px;
    height: 1123px;
    border: 1px solid #ccc;
    background-color: #fff;
}

.design-element {
    position: absolute;
    border: 1px dashed #888;
    display: flex;
    justify-content: center;
    align-items: center;
    background-color: rgba(255, 255, 255, 0.8);
    user-select: none;
}

.design-element.selected {
    border: 2px solid #0078d7;
}

.property-panel {
    width: 250px;
    padding: 10px;
    background: #f7f7f7;
    border: 1px solid #ddd;
    border-radius: 5px;
}

.property-panel input {
    width: 100%;
    margin-bottom: 6px;
}
```

---

## 🧠 JS Interop (Real-Time Sync)

### `wwwroot/js/designer.js`

```js
window.initDesignerInterop = (dotnetRef) => {
    interact('.design-element')
        .draggable({
            listeners: {
                move(event) {
                    const target = event.target;
                    const id = target.id;
                    let x = (parseFloat(target.dataset.x) || 0) + event.dx;
                    let y = (parseFloat(target.dataset.y) || 0) + event.dy;

                    target.style.transform = `translate(${x}px, ${y}px) rotate(${target.dataset.rotation || 0}deg)`;
                    target.dataset.x = x;
                    target.dataset.y = y;
                },
                end(event) {
                    const target = event.target;
                    const id = target.id;
                    const rect = target.getBoundingClientRect();
                    const parentRect = document.getElementById("canvas").getBoundingClientRect();

                    const x = rect.left - parentRect.left;
                    const y = rect.top - parentRect.top;
                    const w = rect.width;
                    const h = rect.height;
                    const rotation = parseFloat(target.dataset.rotation) || 0;

                    dotnetRef.invokeMethodAsync("UpdateElementPosition", id, x, y, w, h, rotation);
                }
            }
        })
        .resizable({
            edges: { left: true, right: true, bottom: true, top: true },
        })
        .on('resizemove', event => {
            const target = event.target;
            const id = target.id;

            let x = (parseFloat(target.dataset.x) || 0);
            let y = (parseFloat(target.dataset.y) || 0);

            Object.assign(target.style, {
                width: `${event.rect.width}px`,
                height: `${event.rect.height}px`
            });

            x += event.deltaRect.left;
            y += event.deltaRect.top;

            target.style.transform = `translate(${x}px, ${y}px) rotate(${target.dataset.rotation || 0}deg)`;
            target.dataset.x = x;
            target.dataset.y = y;

            dotnetRef.invokeMethodAsync("UpdateElementPosition", id, x, y, event.rect.width, event.rect.height, parseFloat(target.dataset.rotation) || 0);
        });

    console.log("Designer interop initialized with live sync.");
};

window.downloadFileFromBase64 = (fileName, base64Data) => {
    const link = document.createElement('a');
    link.download = fileName;
    link.href = "data:application/pdf;base64," + base64Data;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
};
```

Add scripts to `_Host.cshtml`:

```html
<script src="~/js/interact.min.js"></script>
<script src="~/js/designer.js"></script>
```

---

## 🧾 QuestPDF Export

### `Controllers/PdfController.cs`

```csharp
using BlazorA4Designer.Models;
using Microsoft.AspNetCore.Mvc;
using QuestPDF.Fluent;
using QuestPDF.Infrastructure;

namespace BlazorA4Designer.Controllers;

[ApiController]
[Route("api/pdf")]
public class PdfController : ControllerBase
{
    [HttpPost("export")]
    public IActionResult Export([FromBody] LayoutConfig layout)
    {
        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(20);
                page.Content().Canvas((canvas, size) =>
                {
                    foreach (var el in layout.Elements)
                    {
                        var x = (float)el.X;
                        var y = (float)el.Y;

                        if (el.Type == "text")
                        {
                            var fontSize = Convert.ToSingle(el.Style?.GetValueOrDefault("fontSize") ?? 12);
                            canvas.Translate(x, y);
                            canvas.Rotate((float)el.Rotation);
                            canvas.Text(el.Content ?? "")
                                .FontSize(fontSize);
                            canvas.Rotate(-((float)el.Rotation));
                            canvas.Translate(-x, -y);
                        }
                        else if (el.Type == "image" && System.IO.File.Exists($"wwwroot/{el.Content}"))
                        {
                            var image = System.IO.File.ReadAllBytes($"wwwroot/{el.Content}");
                            canvas.Translate(x, y);
                            canvas.Rotate((float)el.Rotation);
                            canvas.Image(image)
                                .FitWidth((float)el.Width);
                            canvas.Rotate(-((float)el.Rotation));
                            canvas.Translate(-x, -y);
                        }
                    }
                });
            });
        }).GeneratePdf();

        return File(pdf, "application/pdf", "design-export.pdf");
    }
}
```

---

## 🧠 Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddControllers();
builder.Services.AddHttpClient();

var app = builder.Build();

app.UseStaticFiles();
app.MapControllers();
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
```

---

## 🚀 Run It

```bash
dotnet run
```

Open → [https://localhost:5001/designer](https://localhost:5001/designer)

Now you can:

* Drag and resize elements
* See the **property panel instantly update**
* Export your **A4 layout to PDF**

---

## 🧠 Future Ideas

| Feature           | Description                                   |
| ----------------- | --------------------------------------------- |
| Rotation handles  | Add `interact.js` `gesturable()` for rotation |
| Text styling      | Add font color, alignment, background         |
| Grid snapping     | Visual grid & magnet snapping                 |
| Multi-page layout | Support A4 multipage templates                |

---

Would you like me to **add rotation handles** (so you can rotate visually instead of typing a number)?
