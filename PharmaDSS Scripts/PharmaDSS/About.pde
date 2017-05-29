 /* Release Notes:
  *
  * ALPHA V1.0:   The following scripts demonstrate a basic environment for "PharmaDSS" (Decision Support System)
  *               The scripts are a parametric implementation of GSK's "Agile Network Meta-model v7"
  *               developed by Mason Briner and Giovonni Giorgio in U.K. 
  *
  *               The primary purpose of this work is overcome various limitations of excel such as: 
  *               graphics, arithmatic operations, usability, and stochastic variability.
  *
  *               Classes that define primary object abstractions in the system are: 
  *               (a) Profile: NCE demand profile
  *               (b) Site: Factory Location/Area
  *               (c) Build: Manufacturing Unit/Process
  *               (d) Person: "Human Beans", as the BFG would say (i.e. Labor)
  *
  *               The Alpha is designed with the following minimum viable features:
  *                 - Object-oriented framework for model components
  *                 - Profiles, Sites, Builds, and Persons
  *                 - Directly read values from Microsoft Excel, linking GSK (Excel-based) and MIT (Java-based) workflows
  *                 - Basic Visualization of System Inputs
  *
  * ALPHA V1.1:   - Dynamic, Turn-based interaction using mouse and keyboard commands
  *               - Misc Visual:
  *                 - Added peak forecast demand tag to Profiles
  *                 - Added Color Inversion
  *                 - Added turn-based Profile explorer
  *                 - Incorporate 5-yr lead times
  *
  * ALPHA V1.2:   - Dynamic, Turn-based interaction using button and keyboard commands
  *               - Added UI for selecting specific (a)Profiles, (b)Sites, and (c)Builds
  *               - Allocate NCE "Build" capacity between sites
  *               - Enabled "deploy" event that allocates capacity to site in a given turn
  *               - Misc Visual:
  *                 - Add Large-scale format for selected profile for greater legibility
  *                 - Build capacity has 3 states: (1) Under Construction, (2) Active, (3) Inactive/Not utilized 
  *
  * ALPHA V1.3:   - Select Subset of builds in site...remove or repurpose site builds
  *               - Prepopulate Builds
  *               - Random order for XLS PRofiles
  *               - Add Total Capacity to NCEs
  *               - Make Builds and NCEs similar magnitides
  *               - Add Process Graphic to visualization
  *               - Make Screen Resolution Lower/Resizable
  *               - Draw Launch Tick
  *               - Make Version That is Compatible with Small Screens
  *               - Normalize Large-scale Profile graph
  *               - Make Current Year more Visible during GameMode
  *               - Add R&D "modules", specified by limit, to Site Visualization
  *               - Relative scaling for Large-format Profile visualization
  *               - Implement stochastic events not easily performed in excel
  *
  * BETA V1.0:    The 'BETA' is the first version of PharmaDSS that is compatible with a Tactile Matrix.
  *               - Added Table Surface Canvas
  *               - Added Projection Mapping
  *               - Added Colortizer port
  */
  
String VERSION = "BETA V1.0";  
  
 /* TO DO:        - R&D Slot tonnage is not terribly important
  *               - Have 2 modes for batch vs. continuous - continuous effectively makes sites have higher capacity
  *
  *               - Output summary of 5 KPIs
  *                - CAPEX
  *                - OPEX
  *                - Ability to Meet Demand
  *                - Cost of Goods
  *                - Security of Supply
  *
  *               - Allow user/player to "nudge" baseline parameters before proceeding with game (for instance, change assumption about NCE R&D allowed on Sites)
  *               - Include Salary modifier for different Sites
  *               - Switch between weight/cost metrics for Build Types
  *               - Allow user to compare performance with baseline scenario(s)
  *
  *               - Make click-based interface?
  *               - Add Batch/Continuous Mode
  *               - Place into R&D First
  *               - Only fill up production capacities partially on sites
  *               - Update Capacity into future
  *               - Graphic Icons for (a) NCE (molecule?) and (b) Build (Widget?) and (c) R&D (beaker?)
  */
