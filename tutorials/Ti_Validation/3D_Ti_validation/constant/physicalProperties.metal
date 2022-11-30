/*--------------------------------*- C++ -*----------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     | Website:  https://openfoam.org
    \\  /    A nd           | Version:  10
     \\/     M anipulation  |
\*---------------------------------------------------------------------------*/
FoamFile
{
    format      ascii;
    class       dictionary;
    location    "constant";
    object      physicalProperties.water;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

viscosityModel  constant;

nu              2.35e-06;

rho             4420;


	Tsolidus 1890;
	Tliquidus 1928.15;
    LatentHeat 2.95653e5;
    beta    5.0e-6;
    
    poly_kappa   (5 1.0e-2 0 0 0 0 0 0);
    poly_cp   (500 0.2 0 0 0 0 0 0);


// ************************************************************************* //
