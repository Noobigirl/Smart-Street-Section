# Background Research & System Logic: Module 1

**Topic:** Bio-Retention Surface & Hydraulic Control  
**Audience:** Project Team & Non-Technical Stakeholders

## Introduction: What is Module 1?

In traditional cities, rain hits concrete and immediately floods into open gutters, carrying trash with it. Module 1 of our smart street system replaces this with a **Bio-Retention Surface**—a strip of engineered soil and grass alongside the road.

This green space acts as a first line of defense: it absorbs water, filters out debris, and features automated "smart gates" (actuators) that open up to drop excess water into an underground tunnel when a heavy storm hits. This document explains the logic and math behind how we are simulating this.

---

## 1. Calculating Rainwater: The Rational Method

To simulate our street, we first need to know how much water is actually hitting the drain. Civil engineers use a standard formula called the **Rational Method**:

$$Q = C \times I \times A$$

Here is what that means in plain English:
- **$Q$ (Peak Flow):** The maximum amount of water rushing off the street at the worst part of the storm.
- **$I$ (Rain Intensity):** How hard it is raining (e.g., light drizzle vs. tropical monsoon).
- **$A$ (Area):** The physical size of our street section.
- **$C$ (Runoff Coefficient):** A rating of how "slippery" a surface is.
  - Concrete has a high $C$ value (around 0.85) because water bounces right off it.
  - A grassy lawn has a low $C$ value (around 0.15) because it absorbs water.

### Why We Use a "Composite" Coefficient

Our street isn't just one material—it is a mix of asphalt (the road) and grass (the bio-retention strip). If we treat the whole street like concrete, our math will say there is too much flooding. If we treat it all like grass, our math will say there is no flooding.

**The Solution:** We calculate a *Composite Runoff Coefficient* by blending the two values based on how much space each takes up.

> **Note for the team:** The Rational Method gives us the absolute peak worst-case scenario to ensure our pipes are big enough; it doesn't give us a minute-by-minute timeline of the storm.

---

## 2. The Green Infrastructure: Soil & Grass Choices

### The Soil: Engineered Bioretention Soil Mix (BSM)

Originally, we considered Peat soil because it absorbs a massive amount of water (like a sponge). However, for urban drainage, a sponge is actually bad. If the soil stays soaked for days, the *next* rainstorm will cause an immediate flood.

Instead, we are using an **Engineered Soil Mix (BSM)** made mostly of coarse sand, mixed with a little clay and compost.
- **Why?** It drains water extremely fast (high hydraulic conductivity) straight into the underground system, but still has enough clay to physically filter out heavy metals and pollutants from car tires.

### The Grass: Centipede Grass

We chose Centipede Grass (*Eremochloa ophiuroides*) for the surface.
- **Why?** It grows in a dense, tangled mat that acts like a physical comb/filter to trap trash and sediment before it hits our drains. It also grows very slowly (meaning the city doesn't have to mow it often) and thrives in the nutrient-poor engineered sand we are using.

---

## 3. The Math Behind the Simulation: "Water Balance"

When we code the simulation, the computer needs to track where every single drop of water goes so that no water magically disappears or duplicates. We use a **Water Balance Equation**, which works exactly like a bathtub:

$$\text{Water In (Rain)} - \text{Water Out (Absorbed + Drained)} = \text{Water Stored (Puddles)}$$

At every second in our simulation, the software runs this accounting check. If the soil is completely full and the rain is falling faster than the soil can absorb it, the "Water Stored" on the surface starts to rise.

---

## 4. The Smart Gates: Actuator Logic

Every 100 meters, our bio-retention channel has automated gates (actuators) that can open to drop water directly into a massive underground tunnel. But how does the computer know *when* to open them?

### The Wrong Way: Soil Moisture Sensors

At first, we thought about using sensors inside the dirt. If the dirt is 100% wet, open the gate!
- **The Flaw:** Soil stays wet for days after a storm ends. If we use soil moisture, the gates will stay open all week, which is dangerous for pedestrians and defeats the purpose of the system.

### The Right Way: Surface Water Depth & Flow Rate

Instead, our system triggers based on what is happening *above* ground:

1. **Surface Puddling:** An ultrasonic sensor bounces soundwaves off the ground. If standing water (the puddle) gets deeper than 5 centimeters, it means the soil is overwhelmed, and the gate opens.
2. **Flash Flood Velocity:** A flow sensor measures how fast water is rushing in. If a sudden monsoon hits and the water volume crosses a danger threshold, the gate opens instantly, before puddles even have time to form.

Once the rain stops and the surface water drains away, a safety "cooldown timer" ticks down for 5 minutes, and then the gates safely close themselves.

### Actuator Control Function

$$c_{\text{Actuator State}}(t) = \begin{cases} 
  \text{OPEN}, & \text{if } h(t) \ge H_{\text{TRIGGER}\_\text{OPEN}} \text{ or } Q_{\text{in}}(t) \ge Q_{\text{TRIGGER}\_\text{OPEN}} \\ 
  \text{CLOSED}, & \text{if } h(t) < H_{\text{TRIGGER}\_\text{OPEN}} \text{ and Cooldown Timer elapsed} 
\end{cases}$$
