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

Converts raw weather events into volumetric flow rates hitting the street section.

  

-   **Simulated sensor:** **Virtual Tipping-Bucket Rain Gauge** (measures real-time rainfall intensity).
    
      
    
-   **Primary Inputs:**
    
      
    -   Precipitation Intensity ($I$, in $\text{mm/hr}$)
        
          
        
    -   Surface Areas ($A_{\text{pavement}}$ and $A_{\text{bioretention}}$, in $\text{m}^2$)
        
          
        
    -   Simulation Time Step ($\Delta t$, in seconds)
        
          
        
-   **Processing Logic:**
    
      
    
    $$Q_{\text{in}} = \frac{C_{\text{composite}} \cdot I \cdot (A_{\text{pavement}} + A_{\text{bioretention}})}{3.6 \times 10^6} \quad [\text{m}^3/\text{s}]$$
    
-   **Stage Outputs:**
    
      
    -   `volume_in_step`: Volume of water added to surface in the current tick ($\text{Liters}$).
        
          
        

### Stage 2: Bio-Retention Infiltration & Soil Mass Balance

Tracks water soaking into the soil versus water ponding on the surface.

  

-   **Simulated sensors:**
    
      
    -   **Sub-Surface Volumetric Water Content (VWC) Sensor** (e.g., TDR equivalent) at $10\text{ cm}$ and $30\text{ cm}$ depths to measure soil saturation percentage ($\theta$).
        
          
        
    -   **Ultrasonic Surface Water Level Sensor** mounted above the channel to measure standing head height ($h$).
        
          
        
-   **Primary Inputs:**
    
      
    -   `volume_in_step` ($\text{Liters}$ from Stage 1)
        
          
        
    -   `soil_max_capacity` (Maximum moisture volume the BSM layer can retain)
        
          
        
    -   `soil_k_sat` (Max hydraulic conductivity of the BSM)
        
          
        
-   **Processing Logic:**
    
    Determines actual infiltrated volume based on available soil capacity and incoming water, updates soil saturation state, and calculates any remaining unabsorbed surface water depth ($h_{t+1}$ in $\text{mm}$).
    
      
    
-   **Stage Outputs:**
    
      
    -   `soil_saturation_pct`: Updated moisture value mapped to the VWC sensor UI.
        
          
        
    -   `surface_water_depth_mm`: Standing water depth mapped to the Ultrasonic sensor UI.
        
          
        

### Stage 3: Actuator Decision Logic & Mechanical State Machine

Evaluates hydraulic thresholds to execute channel gate commands and prevent surface flooding.

  

-   **Simulated sensors:**
    
      
    -   **Differential Pressure Flow Sensor** to measure flow rate entering the drain.
        
          
        
    -   **Limit Switches** to confirm if the actuator gate is physically open or closed in the 3D space.
        
          
        
-   **Primary Inputs:**
    
      
    -   `surface_water_depth_mm` ($h$, from Stage 2)
        
          
        
    -   `Q_in_lps` (Instantaneous flow from Stage 1)
        
          
        
    -   Thresholds: `H_TRIGGER_OPEN` (e.g., $50\text{ mm}$ surface water) and `Q_TRIGGER_OPEN`
        
          
        
-   **Processing Logic:**
    
    The system bypasses soil moisture sensors for trigger logic. Instead, it triggers strictly on surface head height or critical peak flow, enforcing a safety cooldown timer before closing.
    
      
    
$${\text{Actuator State}}(t) = \begin{cases} 
  \text{OPEN}, & \text{if } h(t) \ge H_{\text{TRIGGER}\_\text{OPEN}} \text{ or } Q_{\text{in}}(t) \ge Q_{\text{TRIGGER}\_\text{OPEN}} \\ 
  \text{CLOSED}, & \text{if } h(t) < H_{\text{TRIGGER}\_\text{OPEN}} \text{ and Cooldown Timer elapsed} 
\end{cases}$$
    
-   **Stage Outputs:**
    
      
    -   `actuator_state`: Physical boolean state passed to the Godot 3D animation tree (`OPEN` / `CLOSED`).
        
          
        
    -   `Q_actuator_diverted`: Calculated volume of water successfully diverted away from the surface into the underground system ($\text{L/s}$).
