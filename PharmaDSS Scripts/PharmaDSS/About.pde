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
  *               (a) Profile: NCE demand profile
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
  *               - Allocate NCE "Build" capacity between sites
  *               - Enabled "deploy" event that allocates capacity to site in a given turn
  *               - Add Large-scale format for selected profile for greater legibility
  *               - Build capacity has 3 states: (1) Under Construction, (2) Active, (3) Inactive/Not utilized 
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
  *               - Add Clear Legend for NCE Typology in Game
  *               - Check that launch dates are correct...
  *               - Link 1 Lego Unit to a custom Build Type that is displayed on the the table margin
  *               - Only fill up production capacities partially on sites
  *               - Make Selected NCE Profile Full Screen When Docked
  *               - Add Per-site COGs to large Profile Visualization
  *               - Make NCE Dock for NCE selection
  *
  * BETA V1.1:    - Added OPEX Calc
  *               - Added COGs Calc
  *               - Output summary of 5 KPIs(CAPEX, OPEX, Ability to Meet Demand, Cost of Goods, Security of Supply)
  *               - Visualize site bins
  *                 -Capacity loading bar colors
  *                 -greenfield line
  *               - Click based 
  *               - Graphic Icons for NCE (molecule)
  *               - Make sure screen updates when NCE is docked
  *               - Make Sure NCE selects ABSOLUTE Profile, not ORDER of Active Profile
  *               - Link Colortizer Variables (ID + rot) to PharmaDSS Variables
  *               - No longer Remove Profiles From Game Once they Fail
  *               - Edited Current Turn Indicator; Reveals Future Demand 1-yr out
  *               - Clarify Current Year VS other milestones in NCE profile graph
  *               - Have "Chip" Visualization shown initially, at least until first turn is progressed
  *               - NCE Actual Demand should reveal 1 year sooner
  *               - Colortizer Integration: Allow Adding/Removing Within Same Turn
  *               - Efficiency / Value Visualization should be distinct/seperate, perhaps put into toggle-able layers
  *               - Only use radar for normalized values
  *
  * BETA V1.2:    - Bug Fix: Improved Framerates Drastically!
  *               - New Feature: Allow Click when mouse dragged
  *               - New Feature: Update Button Animation
  *               - New Feature: Automatically Initializes in "Game Mode"
  *               - Refactoring:  Menu + Buttons for easy updating
  *               - Bug Fix: Deploy correct NCE when clicking table in game mode
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
  *               - BugFix: Increase Scale Height of NCE Graphs
  *               - BugFix: Future Capacity Viz Simplified
  *               - Edit: Change Size of Site 2 in XLS File
  *               - BugFix: Show NCEs when no actual demand (i.e. NCE 4 & 7)
  *               - BugFix: Future Capacity Viz When Repurposing too long
  *
  * BETA V1.4:    - New Feature: Incorporate Site "Slices" into Interface Design
  *               - New Feature: Update NCE Dock and Graphics
  */
  
String VERSION = "BETA V1.4";
  
 /* TO DO:    
 
  ***               - Allow variable Chip Tonnage
  ***               - Allow user to compare performance with baseline/batch/ideal scenario(s)  
  ***               - Clean-up / Simplify 5 Game Scores to ~3
  ***               - Have Random-ish visualization of NCE generation from candidacy to launch; Random NCE Generation
  ***               - Implement Automated Stochastic NCE demand profiles w/ random events
  ***               - Implement/Polish Game Setup Files
  
  *                - Therepuetic Area is correllated to Peak Demand
  *                  - Respiratory
  *                  - Oncology
  *                  - Inflammatory
  *                  - HIV/Immuno
  
  *               - "Ghost" of hypothetical player to play against
  
  *               - Priority: (1) R&D, (2) Batch vs Continuous, (3) Random Events
  
  *               - Clarify Greenfield/Existing Site Effect (Different construction bar for greenfield development?)
  *               - Clarify on projection/site that capacity dedicated to a failed NCE market is available for redevelopment
  *               - Somehow add screen-based deployments to table?
  
  *               - Toggle Visualization to emphasize SITE vs OUTPUTS (i.e. have "expanded mode" for graphs of score)
  *               - Distinguish between user and "AI"/predicted
  
  *               - Rebuild Site Visualizations, particularly how builds are represented
  
  *               - Create Dynamic Relative Scale for Profiles (Small Version + Large Version)
  
  *               - Update Future Capacity for Removed Builds (not just added Builds)

  *               - Account for repurposing / building cost differently
  *               - Don't Allow Player to over-pack a site
  
  *               - Have Demand automatically produced in cheaper sites FIRST
  *               - Have Security of Supply influenced by monte carlo calc?

  *               - Add R&D slot to table visualization
  *               - Add Batch/Continuous Mode (continuous effectively makes sites have higher capacity)
                 
  *               - Allow user/player to "nudge" baseline parameters before proceeding with game (for instance, change assumption about NCE R&D allowed on Sites)
  *               - Include Salary modifier for different Sites  
  *               - Filter for NEC-specific performance?
  *
  *               - Draw Build Ghosts on All of Site?
  *               - "NCE Not Available" Error when in NCE dock
  
  *               - Graphic Icons (b) Build (Widget?) and (c) R&D (beaker)
  *               - Text feed back for game play
  *                 - Can't Repurpose while Under Construction
  *                 - Site has no production!
  *                 - out of room! (over cap)
  *
  *               - Incorporate Drug Buffer Into Model
  */
 
