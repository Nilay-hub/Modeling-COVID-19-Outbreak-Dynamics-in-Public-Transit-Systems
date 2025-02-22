# 🚍 Modeling COVID-19 Outbreak Dynamics in Public Transit Systems

## 📌 Overview
This project models and simulates **COVID-19 transmission in public transport systems** using an **Agent-Based Model (ABM)**. The simulation represents a bus as a **network of passenger seats** and evaluates how **passenger interactions**, **mask usage**, and **vaccination status** affect disease spread.

By leveraging **NetLogo**, a powerful agent-based modeling platform, we simulate **infection probabilities** and assess different scenarios in a **public transit environment**.

## 🏆 **Key Features**
- **Agent-Based Simulation**: Models individual passengers as agents with unique behaviors.
- **Dynamic Virus Spread**: Simulates transmission rates based on **seating arrangement and exposure time**.
- **Mask & Vaccination Impact**: Evaluates the effect of protective measures.
- **Real-World Transit Data**: Uses **MARTA Bus System (Atlanta, Georgia)** data.
- **Parameter Customization**: Users can modify **infection rates, mask mandates, and passenger density**.

---

## 📂 **Project Structure**
📁 COVID-Transit-Simulation/ │── 📄 README.md # Project documentation │── 📜 CSC8980_FinalProjectCode.nlogo # NetLogo simulation code │── 📄 seatslayout.csv # Seating layout of the transit system │── 📄 TCS Poster Updated.pdf # Research poster detailing the study


---

## 🔬 **Methods & Simulation Approach**
The simulation follows an **Agent-Based Model (ABM)**, where:
1. **Passengers board** the bus at a **Poisson arrival rate**.
2. **Transmission occurs** based on **contact duration and proximity**.
3. **Passengers exit** after a set time, potentially leaving infected individuals.
4. **Mask and vaccination policies** influence infection rates.

### **🦠 Assumptions**
- Direct **respiratory transmission** (no airborne or fomite transmission).
- Passengers board and exit the bus at random intervals.
- Masks reduce transmission probability.

---

## 📈 **Simulation Results**
| Scenario | Total Passengers | Susceptible | Infected |
|----------|----------------|-------------|-----------|
| **No Mask Policy** | 91 | 49 | 13 |
| **With Masks** | 91 | 49 | 11 |

- **Without masks**, **13 passengers** became infected.
- **With masks**, the infection dropped to **11 passengers**.
- **Vaccination rates** can further **reduce** spread.

---

## 🛠 **How to Run the Simulation**
### 1️⃣ **Prerequisites**
- Install **NetLogo**: [Download here](https://ccl.northwestern.edu/netlogo/)
- Download the dataset (`seatslayout.csv`).

### 2️⃣ **Running the Model**
1. Open **NetLogo**.
2. Load `CSC8980_FinalProjectCode.nlogo`.
3. Adjust parameters (e.g., mask usage, transmission rate).
4. Click **Run Simulation**.
5. Observe how infection spreads in different scenarios.

---

## 🔬 **Applications in Healthcare**
This model helps **public health experts** and **transportation authorities**:
- **Assess risks** of **virus transmission in transit** systems.
- **Develop policies** like **mask mandates & social distancing**.
- **Optimize bus layouts** to **reduce infections**.

---

## 📢 **Acknowledgments**
- **Authors**: **Dattu Reddy Maddur & Nilay Nisheethkumar Patel**  
- **Institution**: **Georgia State University - Computer Science Department**  
- **Advisor**: **Professor Armin R. Mikler, Ph.D**  
