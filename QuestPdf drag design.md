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



# Part 2
Yes — that’s absolutely possible ✅

In fact, **Blazor Server already uses SignalR under the hood**, so you can extend it easily to:

* Auto-save every **5–10 seconds** to the backend (via SignalR hub).
* Manually save on **Ctrl + S**.
* Optionally broadcast design changes to other connected clients (for collaborative editing later — like Figma).

Let’s walk through how to integrate **real-time saving** into the existing Blazor A4 Designer.

Below is a complete **Markdown guide + code** showing how to:

1. Add a **SignalR Hub** for saving layouts
2. Auto-save every few seconds
3. Handle **Ctrl + S** key events to save manually
4. Display save status (Saved / Saving...)

---

# 💾 Real-Time Auto Save (SignalR) for Blazor A4 Designer

---

## 🧱 Updated Project Structure

```
BlazorA4Designer/
│
├── BlazorA4Designer.csproj
├── Program.cs
├── Pages/
│   └── Designer.razor
├── Controllers/
│   └── PdfController.cs
├── Hubs/
│   └── SaveHub.cs
├── Models/
│   ├── LayoutConfig.cs
│   └── DesignElement.cs
└── wwwroot/
    ├── css/
    │   └── designer.css
    └── js/
        ├── interact.min.js
        ├── designer.js
        └── saveHotkey.js
```

---

## ⚙️ Step 1: Add a SignalR Hub

### `Hubs/SaveHub.cs`

```csharp
using BlazorA4Designer.Models;
using Microsoft.AspNetCore.SignalR;

namespace BlazorA4Designer.Hubs;

public class SaveHub : Hub
{
    private static readonly string SavePath = Path.Combine("App_Data", "autosave.json");

    public async Task SaveLayout(LayoutConfig layout)
    {
        Directory.CreateDirectory("App_Data");
        var json = System.Text.Json.JsonSerializer.Serialize(layout, new()
        {
            WriteIndented = true
        });
        await File.WriteAllTextAsync(SavePath, json);
        await Clients.Caller.SendAsync("Saved", DateTime.UtcNow);
    }

    public async Task<LayoutConfig> LoadLayout()
    {
        if (File.Exists(SavePath))
        {
            var json = await File.ReadAllTextAsync(SavePath);
            return System.Text.Json.JsonSerializer.Deserialize<LayoutConfig>(json)
                   ?? new LayoutConfig();
        }

        return new LayoutConfig();
    }
}
```

This hub lets clients call:

* `SaveLayout(layout)` — store the JSON on disk
* `LoadLayout()` — reload the last autosaved version

---

## ⚙️ Step 2: Register SignalR in `Program.cs`

```csharp
using BlazorA4Designer.Hubs;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddControllers();
builder.Services.AddSignalR();
builder.Services.AddHttpClient();

var app = builder.Build();

app.UseStaticFiles();
app.MapControllers();
app.MapBlazorHub();
app.MapHub<SaveHub>("/savehub");
app.MapFallbackToPage("/_Host");

app.Run();
```

---

## 🧠 Step 3: Auto-Save Logic in Blazor Page

Modify your **`Designer.razor`** page to connect to the SignalR hub and auto-save periodically.

### Add fields & methods:

```razor
@using Microsoft.AspNetCore.SignalR.Client
@inject NavigationManager Nav

<h3>🎨 A4 Designer</h3>
<p><strong>Status:</strong> @SaveStatus</p>

<div class="main-container">
    <!-- Canvas and property panel (same as before) -->
    ...
</div>

@code {
    private LayoutConfig Layout { get; set; } = new();
    private DesignElement? SelectedElement;
    private HubConnection? hubConnection;
    private string SaveStatus = "Not saved";

    protected override async Task OnInitializedAsync()
    {
        hubConnection = new HubConnectionBuilder()
            .WithUrl(Nav.ToAbsoluteUri("/savehub"))
            .WithAutomaticReconnect()
            .Build();

        hubConnection.On<DateTime>("Saved", (time) =>
        {
            SaveStatus = $"Saved at {time:T}";
            InvokeAsync(StateHasChanged);
        });

        await hubConnection.StartAsync();

        // Load previous autosave
        Layout = await hubConnection.InvokeAsync<LayoutConfig>("LoadLayout");

        // Start auto-save every 10 seconds
        _ = AutoSaveLoop();
    }

    private async Task AutoSaveLoop()
    {
        while (true)
        {
            await Task.Delay(10000); // 10s
            await SaveLayout();
        }
    }

    private async Task SaveLayout()
    {
        if (hubConnection?.State == HubConnectionState.Connected)
        {
            SaveStatus = "Saving...";
            await hubConnection.InvokeAsync("SaveLayout", Layout);
        }
    }

    private async Task HandleKeydown(KeyboardEventArgs e)
    {
        if (e.CtrlKey && e.Key == "s")
        {
            e.PreventDefault();
            await SaveLayout();
        }
    }

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (firstRender)
        {
            await JS.InvokeVoidAsync("initDesignerInterop", DotNetObjectReference.Create(this));
            await JS.InvokeVoidAsync("initSaveHotkey", DotNetObjectReference.Create(this));
        }
    }

    [JSInvokable]
    public async Task TriggerSaveShortcut()
    {
        await SaveLayout();
    }
}
```

---

## 🧠 Step 4: JavaScript for Ctrl + S Hotkey

### `wwwroot/js/saveHotkey.js`

```js
window.initSaveHotkey = (dotnetRef) => {
    document.addEventListener('keydown', function (e) {
        if ((e.ctrlKey || e.metaKey) && e.key === 's') {
            e.preventDefault();
            dotnetRef.invokeMethodAsync('TriggerSaveShortcut');
        }
    });
    console.log("Ctrl+S save shortcut enabled");
};
```

Add this script to `_Host.cshtml`:

```html
<script src="~/js/saveHotkey.js"></script>
```

---

## 💾 Step 5: Visual Save Feedback

You already have a `SaveStatus` string bound to the UI:

```razor
<p><strong>Status:</strong> @SaveStatus</p>
```

It will show:

* “Saving…” during auto-save
* “Saved at HH:MM:SS” after save completes

---

## 🧠 Step 6: Auto Load on Startup

When the Blazor component initializes, it calls:

```csharp
Layout = await hubConnection.InvokeAsync<LayoutConfig>("LoadLayout");
```

So any previously autosaved design (in `App_Data/autosave.json`) is automatically loaded.

---

## ✅ How It Works

| Action        | Trigger       | Result                       |
| ------------- | ------------- | ---------------------------- |
| Auto-save     | Every 10 s    | Layout JSON sent via SignalR |
| Manual save   | Ctrl + S      | Instant save                 |
| Startup       | On first load | Auto-load last saved layout  |
| Save feedback | SignalR event | Shows "Saved at HH:MM:SS"    |

---

## 🚀 Run It

```bash
dotnet run
```

Then open:
👉 **[https://localhost:5001/designer](https://localhost:5001/designer)**

Try:

* Move or resize a few items
* Wait 10 seconds → “Saved at 10:42:15” appears
* Press **Ctrl + S** → instant save

Check the saved JSON:
`BlazorA4Designer/App_Data/autosave.json`

---

## 🔮 Optional Upgrades

| Feature               | Description                                       |
| --------------------- | ------------------------------------------------- |
| Cloud sync            | Save JSON to Azure Blob or database               |
| Collaborative editing | Broadcast design changes to all connected clients |
| Version history       | Append timestamped JSONs                          |
| Offline cache         | Auto-restore if disconnected                      |

---

Would you like me to extend this next into **multi-user collaborative editing** (so multiple designers can edit the same layout live using SignalR)?


# Part 3
Excellent — let’s make this **local hybrid autosave system** more complete by adding a **snapshot recovery panel** directly into your Blazor Designer.

This gives you a full “local Figma-like” workflow:

* Auto-save + snapshot rotation
* Manual Ctrl + S save
* Snapshot history list
* Load or restore old snapshots
* Visual status feedback (Saved / Saving / Restored from X)

---

# 🧾 Blazor Designer — Hybrid Local Autosave + Snapshot Recovery

---

## ✅ New Features Added

| Feature            | Description                                  |
| ------------------ | -------------------------------------------- |
| 💾 Auto-Save       | Every 10 s (via SignalR)                     |
| ⌨️ Ctrl + S        | Manual save shortcut                         |
| 🕒 Snapshots       | Timestamped backups (10 latest)              |
| 🔁 Recovery Panel  | Restore any older snapshot                   |
| 📁 Local Storage   | Uses `/App_Data/Layouts/default/` as “cloud” |
| 💬 Status Feedback | Shows “Saved at…”, “Restored from snapshot…” |

---

## 🧱 Folder Layout

```
App_Data/
└── Layouts/
    └── default/
        ├── autosave.json
        └── snapshots/
            ├── snapshot_20251111_144500.json
            ├── snapshot_20251111_145000.json
            └── ...
```

---

## 🧩 1. Updated SaveHub (Server Side)

We’ll add a **`ListSnapshots`** method and a **`LoadSnapshot`** method to the existing hub.

### `Hubs/SaveHub.cs`

```csharp
using BlazorA4Designer.Models;
using Microsoft.AspNetCore.SignalR;
using System.Text.Json;

namespace BlazorA4Designer.Hubs;

public class SaveHub : Hub
{
    private static readonly string DataDir = Path.Combine("App_Data", "Layouts", "default");
    private static readonly string SnapshotDir = Path.Combine(DataDir, "snapshots");
    private static readonly string AutosaveFile = Path.Combine(DataDir, "autosave.json");
    private const int MaxSnapshots = 10;

    public SaveHub()
    {
        Directory.CreateDirectory(DataDir);
        Directory.CreateDirectory(SnapshotDir);
    }

    public async Task SaveLayout(LayoutConfig layout)
    {
        var json = JsonSerializer.Serialize(layout, new JsonSerializerOptions { WriteIndented = true });

        // Autosave
        await File.WriteAllTextAsync(AutosaveFile, json);

        // Snapshot
        var snapshotPath = Path.Combine(SnapshotDir, $"snapshot_{DateTime.UtcNow:yyyyMMdd_HHmmss}.json");
        await File.WriteAllTextAsync(snapshotPath, json);

        // Cleanup
        var snapshots = Directory.GetFiles(SnapshotDir, "*.json")
                                 .OrderByDescending(f => f)
                                 .Skip(MaxSnapshots)
                                 .ToList();

        foreach (var file in snapshots)
            File.Delete(file);

        await Clients.Caller.SendAsync("Saved", DateTime.UtcNow);
    }

    public async Task<LayoutConfig> LoadLayout()
    {
        // Try autosave first
        if (File.Exists(AutosaveFile))
        {
            var json = await File.ReadAllTextAsync(AutosaveFile);
            return JsonSerializer.Deserialize<LayoutConfig>(json) ?? new LayoutConfig();
        }

        // Then last snapshot
        var latest = Directory.GetFiles(SnapshotDir, "*.json")
                              .OrderByDescending(f => f)
                              .FirstOrDefault();
        if (latest != null)
        {
            var json = await File.ReadAllTextAsync(latest);
            return JsonSerializer.Deserialize<LayoutConfig>(json) ?? new LayoutConfig();
        }

        return new LayoutConfig();
    }

    public Task<List<string>> ListSnapshots()
    {
        var files = Directory.GetFiles(SnapshotDir, "*.json")
            .OrderByDescending(f => f)
            .Select(f => Path.GetFileNameWithoutExtension(f)!)
            .ToList();
        return Task.FromResult(files);
    }

    public async Task<LayoutConfig> LoadSnapshot(string snapshotName)
    {
        var path = Path.Combine(SnapshotDir, snapshotName + ".json");
        if (File.Exists(path))
        {
            var json = await File.ReadAllTextAsync(path);
            return JsonSerializer.Deserialize<LayoutConfig>(json) ?? new LayoutConfig();
        }
        throw new FileNotFoundException("Snapshot not found", snapshotName);
    }
}
```

---

## 🧩 2. Update `Designer.razor` (Client Side)

We’ll now add a **snapshot panel** in the right-hand property section.

### Updated snippet inside `Designer.razor`

```razor
@page "/designer"
@using Microsoft.AspNetCore.SignalR.Client
@using BlazorA4Designer.Models
@inject IJSRuntime JS
@inject NavigationManager Nav
@inject HttpClient Http

<h3>🎨 A4 Designer</h3>

<div class="status-bar">
    <strong>Status:</strong> @SaveStatus
</div>

<div class="main-container">
    <!-- Canvas -->
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

    <!-- Property & Snapshot Panel -->
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

        <hr />

        <h5>🕒 Snapshots</h5>
        <button class="btn btn-sm btn-outline-secondary" @onclick="LoadSnapshots">Refresh</button>
        <ul class="snapshot-list">
            @foreach (var snap in Snapshots)
            {
                <li>
                    <button class="btn btn-link p-0" @onclick="() => RestoreSnapshot(snap)">
                        @snap
                    </button>
                </li>
            }
        </ul>
    </div>
</div>

@code {
    private LayoutConfig Layout = new();
    private DesignElement? SelectedElement;
    private HubConnection? hubConnection;
    private string SaveStatus = "Not saved";
    private List<string> Snapshots = new();

    protected override async Task OnInitializedAsync()
    {
        hubConnection = new HubConnectionBuilder()
            .WithUrl(Nav.ToAbsoluteUri("/savehub"))
            .WithAutomaticReconnect()
            .Build();

        hubConnection.On<DateTime>("Saved", (time) =>
        {
            SaveStatus = $"💾 Saved at {time:T}";
            InvokeAsync(StateHasChanged);
        });

        await hubConnection.StartAsync();

        Layout = await hubConnection.InvokeAsync<LayoutConfig>("LoadLayout");
        await LoadSnapshots();
        _ = AutoSaveLoop();
    }

    private async Task AutoSaveLoop()
    {
        while (true)
        {
            await Task.Delay(10000);
            await SaveLayout();
        }
    }

    private async Task SaveLayout()
    {
        if (hubConnection?.State == HubConnectionState.Connected)
        {
            SaveStatus = "Saving...";
            await hubConnection.InvokeAsync("SaveLayout", Layout);
        }
    }

    private async Task LoadSnapshots()
    {
        if (hubConnection != null)
            Snapshots = await hubConnection.InvokeAsync<List<string>>("ListSnapshots");
    }

    private async Task RestoreSnapshot(string name)
    {
        if (hubConnection == null) return;
        Layout = await hubConnection.InvokeAsync<LayoutConfig>("LoadSnapshot", name);
        SelectedElement = null;
        SaveStatus = $"🔁 Restored from {name}";
        await InvokeAsync(StateHasChanged);
    }

    // same AddText, AddImage, GetElementStyle, etc. as before
}
```

---

## 🧠 3. Simple CSS additions

Add to `designer.css`:

```css
.status-bar {
    margin-bottom: 8px;
}

.snapshot-list {
    list-style: none;
    padding-left: 0;
    max-height: 150px;
    overflow-y: auto;
}

.snapshot-list li {
    margin-bottom: 4px;
}

.snapshot-list button {
    font-size: 0.85rem;
    text-align: left;
}
```

---

## 💾 4. Behavior

| Action                | What Happens                          |
| --------------------- | ------------------------------------- |
| Auto-save every 10 s  | Writes autosave.json + snapshot       |
| Ctrl + S              | Forces save                           |
| Refresh snapshot list | Lists local snapshot files            |
| Click a snapshot      | Restores that version immediately     |
| Startup               | Loads autosave or newest snapshot     |
| Status bar            | Shows “Saved at” or “Restored from …” |

---

## 🧠 5. Optional enhancements

| Enhancement          | How                                |
| -------------------- | ---------------------------------- |
| Compress snapshots   | GZip files on disk                 |
| Delete snapshot      | Add “🗑️” button next to each      |
| Restore confirmation | Prompt user before overwrite       |
| Preview snapshot     | Render miniature canvas            |
| Diff view            | Compare elements between snapshots |

---

## ✅ End Result

You now have a **Blazor A4 Designer** that:

* Auto-saves your layout locally
* Creates timestamped backup snapshots
* Lets you restore any previous version instantly
* Behaves like a small-scale “local Figma” without relying on RAM or cloud storage

---

Would you like me to add **snapshot compression + cleanup rotation (e.g., keep 5 days worth)** next? That would make the storage more efficient if you run this long-term.
