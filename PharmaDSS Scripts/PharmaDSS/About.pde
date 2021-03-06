 /* PharmaDSS - Pharmaceutical Decision Support System
  *
  * MIT LICENSE:  Copyright 2017 Ira Winder et al.
  *
  *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
  *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
  *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
  *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
  *               furnished to do so, subject to the following conditions:
  *
  *               The above copyright notice and this permission notice shall be included in all copies or 
  *               substantial portions of the Software.
  *
  *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
  *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
  *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
  *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
  *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  *
  * DESCRIPTION:  Enclosed scripts demonstrate an environment for "PharmaDSS" (Pharmaceutical Decision Support System)
  *               The scripts are a parametric implementation of GSK's "Agile Network Meta-model v7"
  
  *               developed by Mason Briner and Giovanni Giorgio in U.K. 
  *
  *               The primary purpose of this work is to overcome various limitations of excel such as: 
  *               graphics, arithmatic operations, usability, and stochastic variability.
  *
  *               This script will also be compatible with the "Tactile Matrix," a tangible Lego interface 
  *               developed by Ira Winder at the MIT Media Lab.
  *
  *               Classes that define primary object abstractions in the system are: 
  *               (a) Profile: API demand profile
  *               (b) Site: Factory Location/Area
  *               (c) Build: Manufacturing Unit/Process
  *               (d) Person: "Human Beans", as the BFG would say (i.e. Labor)
  *  
  * ALPHA V1.0:   - Object-oriented framework for model components
  *               - Profiles, Sites, Builds, and Persons
  *               - Directly read values from Microsoft Excel, linking GSK (Excel-based) and MIT (Java-based) workflows
  *               - Basic Visualization of System Inputs
  *
  * ALPHA V1.1:   - Dynamic, Turn-based interaction using mouse and keyboard commands
  *               - Added peak forecast demand tag to Profiles
  *               - Added Color Inversion
  *               - Added turn-based Profile explorer
  *               - Incorporate 5-yr lead times
  *
  * ALPHA V1.2:   - Dynamic, Turn-based interaction using button and keyboard commands
  *               - Added UI for selecting specific (a)Profiles, (b)Sites, and (c)Builds
  *               - Allocate API "Build" capacity between sites
  *               - Enabled "deploy" event that allocates capacity to site in a given turn
  *               - Add Large-scale format for selected profile for greater legibility
  *               - Build capacity has 3 states: (1) Under Construction, (2) Active, (3) Inactive/Not utilized 
  *
  * ALPHA V1.3:   - Select Subset of builds in site...remove or repurpose site builds
  *               - Prepopulate Builds
  *               - Random order for XLS PRofiles
  *               - Add Total Capacity to APIs
  *               - Make Builds and APIs similar magnitides
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
  * BETA V1.0:    - The 'BETA' is the first version of PharmaDSS that is compatible with a Tactile Matrix.
  *               - Added Table Surface Canvas
  *               - Added Projection Mapping
  *               - Added Colortizer port
  *               - Link Site Basins to PharmaDSS Basins
  *               - Add Greenfield capacity to Site Basins
  *               - Randomization of Site (2-3 of various sizes)
  *               - Allow Resetting of Values to Original Spreadsheet
  *               - Added Button for loading original XLS game data
  *               - Create turn-by-turn record or table state
  *               - Draw Colortizer/Table State onto 'offscreen'
  *               - Included GSK Logo
  *               - Add cell Identifiers for Tabletop#
  *               - Phase graphic + communication inside the graphics 
  *               - Radar clean
  *               - Stable buttons
  *               - Spatial reorganization of cards
  *               - Dynamic font resizing
  *               - Line graph for metrics over time
  *               - Mouse interaction with Profiles and line graph
  *               - Added Ability to Meet Demand Calc
  *               - Added Unique Colors for Icons
  *               - Show "Futurevision" for capacity
  *               - Add Turn-By-Turn Graph of Performance
  *               - Graph Class for (a) holding output metrics and (b) allowing clickable mouse interface
  *               - Added CAPEX Calc
  *               - Emphasize Output "Graph" during game (not radar)
  *               - Polish Screen-based Site Visualization
  *               - if add/remove a piece in the same turn, no penalty
  *               - Add Clear Legend for API Typology in Game
  *               - Check that launch dates are correct...
  *               - Link 1 Lego Unit to a custom Build Type that is displayed on the the table margin
  *               - Only fill up production capacities partially on sites
  *               - Make Selected API Profile Full Screen When Docked
  *               - Add Per-site COGs to large Profile Visualization
  *               - Make API Dock for API selection
  *
  * BETA V1.1:    - Added OPEX Calc
  *               - Added COGs Calc
  *               - Output summary of 5 KPIs(CAPEX, OPEX, Ability to Meet Demand, Cost of Goods, Security of Supply)
  *               - Visualize site bins
  *                 -Capacity loading bar colors
  *                 -greenfield line
  *               - Click based 
  *               - Graphic Icons for API (molecule)
  *               - Make sure screen updates when API is docked
  *               - Make Sure API selects ABSOLUTE Profile, not ORDER of Active Profile
  *               - Link Colortizer Variables (ID + rot) to PharmaDSS Variables
  *               - No longer Remove Profiles From Game Once they Fail
  *               - Edited Current Turn Indicator; Reveals Future Demand 1-yr out
  *               - Clarify Current Year VS other milestones in API profile graph
  *               - Have "Chip" Visualization shown initially, at least until first turn is progressed
  *               - API Actual Demand should reveal 1 year sooner
  *               - Colortizer Integration: Allow Adding/Removing Within Same Turn
  *               - Efficiency / Value Visualization should be distinct/seperate, perhaps put into toggle-able layers
  *               - Only use radar for normalized values
  *
  * BETA V1.2:    - Bug Fix: Improved Framerates Drastically!
  *               - New Feature: Allow Click when mouse dragged
  *               - New Feature: Update Button Animation
  *               - New Feature: Automatically Initializes in "Game Mode"
  *               - Refactoring:  Menu + Buttons for easy updating
  *               - Bug Fix: Deploy correct API when clicking table in game mode
  *               - New Feature: Selection Box Hover over Profiles, Sites, and Builds
  *               - New Feature + Bug Fixes: Table Testing Enabled on PC
  *               - Hot Fix: Allows Repurposing of Modules on Table
  *               - Colortizer Integration: Display Construction/Repurpose Status on Table
  *               - Colortizer Integration: Display Production Utilization On Table
  *               - New Feature: Dynamic Scaling of Profile Axes
  *               - Add Site "Filler" That decays over time
  *               - Refactoring: Tabs, Output Class, Phase Diagram
  *
  * BETA V1.3:    - Show Clearly How User's Actions are tied to score change in any given turn.
  *               - New Feature: "Ghost" for hypothetical scores next turn
  *               - BugFix: Update COGS and OPEX Scores into future
  *               - BugFix: synced profile and output axes
  *               - New Feature: Profile Graphs Rescale Axes when Capacity is Large
  *               - New Feature: Consistent Tile Blockers with Time Until Decommission displayed on Table
  *               - New Feature: Add button for Capital "P" (Profile Zoom-in)
  *               - BugFix: Game Messages Displays in better place
  *               - BugFix: Factories that take "3 years" to build are operable on the 4th year (was operable on the 3rd year)
  *               - Add ticks for years on profile graph
  *               - make it difficult to accidentally place nce build
  *               - BugFix: Correct Output Metrics When Beginning with Demand of Zero
  *               - Edit: Changed Lead Time from 5 years to 3 years
  *               - BugFix: Build Modules are repurposed more quickly when built on site (Lego Table Interface Only)
  *               - BugFix: Increase Scale Height of API Graphs
  *               - BugFix: Future Capacity Viz Simplified
  *               - Edit: Change Size of Site 2 in XLS File
  *               - BugFix: Show APIs when no actual demand (i.e. API 4 & 7)
  *               - BugFix: Future Capacity Viz When Repurposing too long
  *
  * BETA V1.4:    - New Feature: Incorporate Site "Slices" into Interface Design
  *               - New Feature: Update API Dock and Graphics
  *               - New Feature: Rebuild Site Visualizations, particularly how builds are represented
  *               - New Feature: Transparent Background for Site Visualization
  *               - BugFix: Fix API Flicker Error
  *               - New Feature: Allow variable Chip Tonnage, Legend for Site Input Slots (Time + chip tonnage)
  *               - Refactor: Reorganized Visualization
  *               - BugFix: Doesn't Crash When Selected API = -1
  *               - BugFix: Correct Display and Value for Chip Capacity
  *               - New Feature: Draw People associated with slices and sites
  *               - New Feature: Refined Table Graphics
  *               - New Feature: Enable 2-3 Sites
  *               - BugFix: No more Random Scores
  *               - BugFix: Production Vs. Capacity Correctly Shows on Tokens
  *               - New Feature: Auto-select API Profile when adding
  *               - BugFix: Fixed Future Score Set When API Fails During Game
  *               - New Feature: Auto-Reset Game When Trying To Progress Past Last Turn
  *               - BugFix(?): siteBuildIndices get mixed up when pieces flicker
  *               - New Feature: Change "NCE" to "API" and named Sites
  *               - Turn off hover-select for APIs when using mouse
  *               - Minor Visualization Figures w/ Giovanni 11/22
  
  */
  
String VERSION = "BETA V1.4";
  
 /* TO DO:    
 
  HotFix        siteBuildIndices get mixed up when pieces flicker
  HotFix        Build Chips Instantly (No "Under Construction" Status)
  HotFix        Automatically Delete Chip When Drug Fails
  HotFix        Clarify tht Score Reflects Current Year, Not Future Year
  HotFix        Clarify which year Capacity in Chips Represents (Next Year?)
  HotFix        Allow Building of Chips on a Slice 1 year before it's finished
  HotFix        Reduce Initial Slices to 2 on both sites for base case
  HotFix        Confirm game reset when advancing turn
  HotFix        Legend for Slice Slots
  HotFix        Are Chip Quantities Intuitive Per Annum? Per Day?
  HotFix        Adjust security score to account for "Slice Diversity," not just "Site Diversity"
  
  
  THU    T04    Clean-up / Simplify 5 Game Scores to ~3
  THU    T05     - Score Visualization / Descriptions
  THU    T07     - Score Logic
  THU    T09    Import new xls scenario
  THU    T01    Implement/Polish Game Setup Files
  THU    T01a    - Number of Sites
  THU    T01b    - Slots Per Slice
  THU    T01c    - Slice Cost
  THU    T01d    - Slice + API Build Time
  THU    T01e    - Days per Year
  THU    T10    Therepuetic Area is correllated to Peak Demand (Have color Codes coorrellate)
  THU    T10a    - Respiratory (Orange?)
  THU    T10b    - Oncology (Green?)
  THU    T10c    - Inflammatory (Teal?)
  THU    T10d    - HIV/Immuno (Purple?)
  THU    T11     - Add API Math Model to PharmaDSS GitHub
  
  NOV  HIGH    01  IW  Allow user to compare performance with baseline/batch/ideal scenario(s)
  NOV  HIGH    01a GG  Develop Batch Rules/AI, Incorporate Drug Buffer Into Model
  NOV  HIGH    01b HK  Develop Batch Index
  NOV  HIGH    02  GG  Have Random-ish visualization of API generation from candidacy to launch, feeding back into R&D
  NOV  HIGH    02a GG  Polish Diagram/Slide
  NOV  HIGH    02b HK  Independent Module
  NOV  HIGH    02c IW  Embed within PharmasDSS
  NOV  HIGH    03  IW  Implement Automated Stochastic API demand profiles
  NOV  LOW     06b GG  Create Document of people associated with slices and sites
  JAN  LOW     07  IW  Clarify on projection/site that capacity dedicated to a failed API market is available for redevelopment (i.e. don't project info and automaticallt remove)
  JAN  THU     T06 HK  Isolate Score/Metrics for a single API
  JAN  MED     08  ??  Text feed back for game play / TUTORIAL
  DEC  HIGH    10  IW  Implement random site events (1 per turn, can be good or bad)
  DEC  MED     05  IW  "Ghost" of hypothetical "perfect" player to play against
  ??   ??      01c HK  Add R&D slots to table visualization
  JAN  LOW     11  IW  Chip Designer/Customizer Slot
  
  */
 
