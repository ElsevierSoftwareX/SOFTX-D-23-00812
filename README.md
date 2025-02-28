# laserbeamFoam

![alt text](https://github.com/micmog/LaserbeamFoam/blob/main/images/Powder.png?raw=true)

## Overview
Presented here is a growing suite of solvers that describe laser-substrate interaction. This repository begn with the laserbeamFoam solver. Additional solvers are being added incrementally.

Currently this repository contains:
### laserbeamFoam
A volume-of-fluid (VOF) solver for studying high energy density laser based advanced manufacturing processes and laser-substrate interactions. In this implementation the metallic substrate, and shielding gas phase, are treated as in-compressible. The solver fully captures the fusion/melting state transition of the metallic substrate. For the vapourisation of the substrate, the explicit volumetric dilation due to the vapourisation state transition is neglected, instead, a phenomenological recoil pressure term is used to capture the contribution to the momentum and energy fields due to vaporisation events. laserbeamFoam also captures surface tension effects, the temperature dependence of surface tension (Marangoni) effects, latent heat effects due to melting/fusion (and vapourisation), buoyancy effects due to the thermal expansion of the phases using a Boussinesq approximation, and momentum damping due to solidification.
A ray-tracing algorithm is implemented that permits the incident Gaussian laser beam to be discretised into a number of 'Rays' based on the computational grid resolution. The 'Rays' of this incident laser beam are then tracked through the domain through their multiple reflections; with the energy deposited by each ray determined through the Fresnel equations. The solver approach is extended from the adiabatic two-phase interFoam code developed by [OpenCFD Ltd.](http://openfoam.com/) to include non-isothermal state transition physics and ray-tracing heat source application.

### array_laserbeamFoam

An extension of laserbeamFoam to N-laser sources that can each have their parameters set independently.


 
 Target applications for the solvers included in this repository include:

* Laser Welding
* Laser Drilling
* Laser Powder Bed Fusion
* Selective Laser Melting
* Diode Array Additive Manufacturing


Users should run the ./Allwclean and ./Allwmake scripts to build the library and solver excecutables


### multiComponentlaserbeamFoam

An extension of the laserbeamfoam solver to multi-component metallic substrates. This solver can simulate M-Component metallic substrates in the prescense of gas-phases. Diffusion is treated through a Fickian diffusion model with the diffusivity specified through 'diffusion pairs', and the interface compression again specified in a pair-wise manner. The miscible phases in the simulation should have diffusivity specified between them., and ine immiscible phase pairs should have an interface compression term specified between them (typically 1).

Target applications for the solvers included in this repository include:

* Dissimilar Laser Welding
* Dissimilar Laser Drilling
* Dissimilar Laser Powder Bed Fusion
* Dissimilar Selective Laser Melting

Users should run the ./Allwclean and ./Allwmake scripts to build the library and solver excecutables


## Installation

The current version of the code utilises the [OpenFoam10 libraries](https://openfoam.org/version/10/). A branch is provided that compiles against the older [OpenFoam6 libraries](https://openfoam.org/version/6/). The code has been developed and tested using an Ubuntu installation, but should work on any operating system capable of installing OpenFoam. To install the laserbeamFoam solver, first follow the instructions on this page: [OpenFoam 10 Install](https://openfoam.org/download/10-ubuntu/) to install the OpenFoam 6 libraries.



Then navigate to a working folder in a shell terminal, clone the git code repository, and build.

```
$ git clone https://github.com/micmog/laserbeamFoam.git laserbeamFoam
$ cd solver
$ wclean
$ wmake
```
The installation can be tested using the tutorial cases described below.

## Tutorial cases
To run any of the tutorials in serial mode:
```
delete any old simulation files, e.g:
$ rm -r 0* 1* 2* 3* 4* 5* 6* 7* 8* 9*
Then:
$ cp -r initial 0
$ blockMesh
$ setFields
$ laserbeamFoam
```
For parallel deployment, using MPI, following the setFields command:
```
$ decomposePar
$ mpirun -np 6 laserbeamFoam -parallel >log &
```
for deployment on 6 cores.

### 2D Plate Examples

In these cases the penetration rate of an incident laser source is investigated based on the angle of incidence of the laser beam. Two cases are presented where the beam is either perpendicular to the substrate or at 45 degrees to the initial plate normal.

### 3D Plate Example

In this case the two-dimensional 45 degree example is extended to three dimensions.

### 2D circular particles Example

In this example a series of circular metallic regions are seeded on top of a planar substrate. The laser heat source traverses along the domain and melts these regions and their topology evolves accordingly.

### 2D Laser-Powder Bed Fusion Example

In this example a two-dimensional domain is seeded with many small powder particles with a complex size distribution, representative of that observed in the L-PBF manufacturing process. The laser heat source traverses the domain and a portion of these particles melt and re-solidify in the heat source wake.

## Algorithm

Initially the solver loads the mesh, reads in fields and boundary conditions, selects the turbulence model (if specified). The main solver loop is then initiated. First, the time step is
dynamically modified to ensure numerical stability. Next, the two-phase fluid mixture properties and turbulence quantities are updated. The discretized phase-fraction equation is then solved for a user-defined number of subtime steps (typically 3) using the multidimensional universal limiter with explicit solution solver [MULES](https://openfoam.org/release/2-3-0/multiphase/). This solver is included in the OpenFOAM library, and performs conservative solution of hyperbolic convective transport equations with defined bounds (0 and 1 for α1). Once the updated phase field is obtained, the program enters the pressure–velocity loop, in which p and u are corrected in an alternating fashion. In this loop T is also solved for, such that he buoyancy predictions are correct for the U and p fields. The process of correcting the pressure and velocity fields in sequence is known as pressure implicit with splitting of operators (PISO). In the OpenFOAM environment, PISO is repeated for multiple iterations at each time step. This process is referred to as merged PISO- semi-implicit method for pressure-linked equations (SIMPLE), or the pressure-velocity loop (PIMPLE) process, where SIMPLE is an iterative pressure–velocity solution algorithm. PIMPLE continues for a user specified number of iterations. 
The main solver loop iterates until program termination. A summary of the simulation algorithm is presented below:
* laserbeamFoam Simulation Algorithm Summary:
  * Initialize simulation data and mesh 
  * WHILE t<t_end DO
  * 1. Update delta_t for stability
  * 2. Phase equation sub-cycle
  * 3. Update interface location for heat source application
  * 4. Update fluid properties
  * 5. Ray-Tracing for Heat Source application at the surface
  * 6. PISO Loop
    * 1. Form u equation
    * 2. Energy Transport Loop
      * 1. Solve T equation
      * 2. Update fluid fraction field
      * 3. Re-evaluate source terms due to latent heat
    * 3. PISO
        * 1. Obtain and correct face fluxes
        * 2. Solve p-Poisson equation
        * 3. Correct u
  * 7. Write Fields
  
There are no constraints on how the computational domain is discretised.

## License
OpenFoam, and by extension the laserbeamFoam application, is licensed free and open source only under the [GNU General Public Licence version 3](https://www.gnu.org/licenses/gpl-3.0.en.html). One reason for OpenFOAM’s popularity is that its users are granted the freedom to modify and redistribute the software and have a right of continued free use, within the terms of the GPL.

## Acknowledgements
Tom Flint and Joe Robson thank the EPSRC for financial support through the associated programme grant LightFORM (EP/R001715/1). Joe Robson further thanks the Royal Academy of Engineering/DSTL for funding through the RAEng/DSTL Chair in Alloys for Extreme Environments.
Philip Cardiff and Gowthaman Parivendhan authors gratefully acknowledge financial support from I-Form, funded by Science Foundation Ireland (SFI) Grant Number 16/RC/3872, co-funded under European Regional Development Fund and by I-Form industry partners. The fourth author additionally acknowledges financial support from the Irish Research Council through the Laureate programme, grant number IRCLA/2017/45, and Bekaert, through the Bekaert University Technology Centre (UTC) at University College Dublin (www.ucd.ie/bekaert). 

## Citing This Work
If you use laserbeamFoam in your work. Please use the following to cite our work:

laserbeamFoam: Laser ray-tracing and thermally induced state transition simulation toolkit
TF Flint, JD Robson, G Parivendhan, P Cardiff - SoftwareX, 2023 - https://doi.org/10.1016/j.softx.2022.101299

Once the SoftwareX 'Software Update' Manuscript is accepted, please cite that if you use the multi-component versions



## References

Flint, T. F., Robson, J. D., Parivendhan, G., & Cardiff, P. (2023). laserbeamFoam: Laser ray-tracing and thermally induced state transition simulation toolkit. SoftwareX, 21, 101299.

Flint, T. F., Parivendhan, G., Ivankovic, A., Smith, M. C., & Cardiff, P. (2022). beamWeldFoam: Numerical simulation of high energy density fusion and vapourisation-inducing processes. SoftwareX, 18, 101065.

Flint, T. F., et al. "A fundamental analysis of factors affecting chemical homogeneity in the laser powder bed fusion process." International Journal of Heat and Mass Transfer 194 (2022): 122985.

Flint, T. F., T. Dutilleul, and W. Kyffin. "A fundamental investigation into the role of beam focal point, and beam divergence, on thermo-capillary stability and evolution in electron beam welding applications." International Journal of Heat and Mass Transfer 212 (2023): 124262.





![visitors](https://visitor-badge.deta.dev/badge?page_id=micmog.LaserbeamFoam)
