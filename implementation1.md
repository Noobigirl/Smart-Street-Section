
# Module 1 Technical Baseline: Bio-Retention Surface & Hydraulic Control

## 1. Composite Runoff Coefficient ($C$) Calibration

### Rationale & Formula:

In a smart street simulation, treating the entire cross-section as a single surface material introduces significant mathematical errors. The designated area consists of both highly impermeable pavement (the road) and highly permeable vegetated bio-retention zones. The system uses a **Composite Runoff Coefficient ($C_{\text{composite}}$)** to average the runoff characteristics based on proportional areas:

  
$$C_{\text{composite}} = \frac{(C_{\text{pavement}} \cdot A_{\text{pavement}}) + (C_{\text{bioretention}} \cdot A_{\text{bioretention}})}{A_{\text{total}}}$$

### Standard Land Use Values:

-   **Impervious Street Pavement:** Downtown/Urban Business Area values range from $0.70 - 0.95$ (Design default: $0.70$).
    
      
    
-   **Bio-Retention Surface:** Flat Lawn with Heavy/Engineered Soil at $2\%$ slope values range from $0.10 - 0.17$ (Design default: $0.10$).
    
      
    

### MATLAB Test Case Calculation:

For a $1000\text{ m}^2$ street section where the asphalt width makes up $800\text{ m}^2$ and the bio-retention grass swale is $200\text{ m}^2$:

  

$$C_{\text{composite}} = \frac{(0.70 \cdot 800) + (0.10 \cdot 200)}{1000} = 0.58$$

## 2. Bio-Retention Soil & Vegetation Specifications

### Selected Soil Media: Standard Engineered Bioretention Soil Mix (BSM)

Raw peat soil is structurally unsuitable for urban drainage due to its severe compaction risk, slow saturated drainage rate, and environmental degradation concerns. The simulation models a standard civil engineering BSM.

  

-   **Composition:** $75\%$ Coarse Concrete Sand (ASTM C33), $15\%$ Soil Fines (Clay/Silt), and $10\%$ Organic Compost.
    
      
    
-   **Hydraulic Conductivity ($K_{\text{sat}}$):** $100 - 300\text{ mm/hr}$. Ensures rapid water infiltration into sub-surface storage without persistent surface ponding.
    
      
    
-   **Porosity ($\phi$):** $35\% - 45\%$ void space for air and water capacity.
    
      
    

### Selected Turfgrass: Centipede Grass (_Eremochloa ophiuroides_)

Centipede grass is a warm-season turfgrass highly suited for shallow-soil urban bioretention channels in humid tropical environments.

  

-   **Runoff Sediment Filtration:** Forms a dense, carpet-like mat via creeping stolons, increasing surface roughness and mechanically trapping suspended sediments.
    
      
    
-   **Low-Maintenance Growth:** Slow vertical growth rate requires minimal simulated mowing logic.
    
      
    
-   **Adaptation to Infertile Soils:** Thrives in nutrient-poor, acidic soils ($\text{pH } 5.0 - 6.0$), perfectly aligning with the BSM profile.
    
      
    

## 3. System Boundary Conditions & Assumptions

### Model Assumptions:

1.  Terrain slope is uniform across the designated street section.
    
      
    
2.  Precipitation is evenly distributed over the entire catchment area $A_{\text{total}}$.
    
      
    
3.  Mechanical reliability of channel actuator gates ($100\%$ uptime during baseline run).
    
      
    
4.  Mechanical actuator response is instantaneous upon receiving command signals.
    
      
    

### Model Limitations (Outside Scope for Module 1):

-   Evapotranspiration dynamics (assumed to be $0\text{ mm/hr}$, negligible over short storm durations).
    
      
    
-   Underground pipe backpressure and pipe friction losses.
    
      
    
-   Chemical pollutant transport dynamics and soil erosion logic.
    
      
    

## 4. Stage-by-Stage Input, Output, and Sensor Mapping

### Stage 1: Surface Precipitation & Overland Runoff Generation

Converts raw weather events into a volumetric amount of water hitting the entire street section per time step.

* **Simulated Sensor:** **Virtual Tipping-Bucket Rain Gauge** (measures real-time rainfall intensity).
* **Primary Inputs:**
* Precipitation Intensity ($I$, in $\text{mm/hr}$)
* Surface Areas ($A_{\text{pavement}}$ and $A_{\text{bioretention}}$, in $\text{m}^2$)
* Simulation Time Step ($\Delta t$, in seconds)


* **Processing Logic:**
Since $1\text{ mm}$ of rain over $1\text{ m}^2$ equals $1\text{ Liter}$, calculate the total Liters generated per second, then multiply by the time step.

$$\text{volume\-in\-step} = \frac{(1-C_{\text{composite}}) \cdot I \cdot (A_{\text{pavement}} + A_{\text{bioretention}})}{3600} \cdot \Delta t \quad [\text{Liters}]$$


* **Stage Outputs:**
* `volume_in_step`: Total volume of water entering the bio-retention surface in the current tick ($\text{Liters}$).



---

### Stage 2: Bio-Retention Infiltration & Soil Mass Balance

Tracks water soaking into the $0.5\text{ m}$ soil layer versus water ponding on the surface, before it passes into the $0.5\text{ m}$ underground channel.

* **Simulated Sensors:**
* **Sub-Surface Volumetric Water Content (VWC) Sensor** (e.g., TDR equivalent) at $10\text{ cm}$ and $30\text{ cm}$ depths to measure soil saturation percentage ($\theta$).
* **Ultrasonic Surface Water Level Sensor** mounted above the channel to measure standing head height ($h$).


* **Primary Inputs:**
* `volume_in_step` ($\text{Liters}$ from Stage 1)
* `soil_porosity` ($\phi \approx 0.40$ for BSM)
* `soil_k_sat` (Max hydraulic conductivity of the BSM, converted to $\text{Liters/s}$)



**Processing Logic:**

1. **Calculate Soil Capacity:**

$$\text{soil\-max\-capacity} = A_{\text{bioretention}} \cdot 0.5\text{ m} \cdot \phi \cdot 1000 \quad [\text{Liters}]$$


2. **Calculate Infiltration:**

$$\text{Vol}_{\text{infilt}} = \min(\text{soil\-k\-sat} \cdot \Delta t, \text{ Available Soil Capacity}, \text{volume\-in\-step} + \text{Surface Water})$$


3. **Update Surface Water Depth ($h$):**

$$h_{t+1} = \frac{(\text{volume\-in\-step} + \text{Previous Surface Water}) - \text{Vol}_{\text{infilt}}}{A_{\text{bioretention}}} \quad [\text{mm}]$$



* **Stage Outputs:**
* `soil_saturation_pct`: Updated moisture value mapped to the VWC sensor UI.
* `surface_water_depth_mm` ($h$): Standing water depth mapped to the Ultrasonic sensor UI.



> **Understanding the Infiltration `min()` Formula**
> The water trying to soak into the ground is limited by three physical boundaries. The `min()` function acts as a reality check to find the active bottleneck:
> 1. **The Speed Limit (`soil_k_sat * time_step`):** The physical maximum rate the dirt can swallow water per second.
> 2. **The Empty Space (`Available Soil Capacity`):** How much room is left in the soil before it hits 100% capacity.
> 3. **The Actual Water (`volume_in_step + Surface Water`):** The new rain from the current time step plus any leftover puddle from the previous step.
> 
> 

**Saturation Calculation & Worked Example**
Saturation is the percentage of the current storage relative to maximum capacity:


$$
\text{Saturation (\%)} =
\left(
\frac{\text{Currently Stored Water}}{\text{Soil Maximum Capacity}}
\right)
\times 100
$$

If one second of time passes ($\Delta t = 1$):

* **Max Capacity:** $1000\text{ Liters}$ total.
* **Current State:** Holds $980\text{ Liters}$ (leaving $20\text{ Liters}$ of **Available Capacity**).
* **Speed Limit:** $15\text{ Liters}$ per second.
* **Water on Top:** $5\text{ Liters}$ of new rain + $2\text{ Liters}$ of previous puddle = $7\text{ Liters}$ total.

$$\text{Vol}_{\text{infilt}} = \min(15, \, 20, \, 7)$$

Because 7 is the smallest constraint, exactly $7\text{ Liters}$ infiltrates.

* The surface puddle drops to $0\text{ Liters}$.
* `currently_stored_water` becomes $987\text{ Liters}$.
* New soil saturation percentage is $98.7\%$.

---

### Stage 3: Actuator Decision Logic & Mechanical State Machine

Evaluates surface puddle height to execute channel gate commands and prevent surface flooding.

* **Simulated Sensors:**
* **Limit Switches** to confirm if the actuator gate is physically open or closed in the 3D space.


* **Primary Inputs:**
* `surface_water_depth_mm` ($h$, from Stage 2)
* Threshold: `H_TRIGGER_OPEN` (e.g., $50\text{ mm}$ surface water)


* **Processing Logic:**
The system uses surface head height to trigger the actuators. Once opened, water bypasses the soil and drops directly into the $0.5\text{ m}$ deep underground channel. A safety cooldown timer is enforced before closing.

$${\text{Actuator State}}(t) = \begin{cases} \text{OPEN}, & \text{if } h(t) \ge H_{\text{TRIGGER\-OPEN}} \\ \text{CLOSED}, & \text{if } h(t) < H_{\text{TRIGGER\-OPEN}} \text{ and Cooldown Timer elapsed} \end{cases}$$


* **Stage Outputs:**
* `actuator_state`: Physical boolean state passed to the Godot 3D animation tree (`OPEN` / `CLOSED`).
