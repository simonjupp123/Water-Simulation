// module heightmap;


// //generate a heightmap from perlin noise to get a square grid of height values
// //this will be used to generate a terrain mesh
// import std.stdio;
// import std.math;
// import std.random;
// import perlin;
// import std.algorithm;

// struct HeightMap
// {
//     float[][] y_vals;
//     int width;
//     int height;

//     this(int width, int height)
//     {
//         this.width = width;
//         this.height = height;
//         this.y_vals = new float[][width];
//         foreach (ref row; this.y_vals)
//         {
//             row = new float[height];
//         }

//     }
// }

// HeightMap generateHeightmapFromFile(string filename, ){

// }

// // HeightMap generateHeightmap(int width, int height, float scale, int offsetX, int offsetZ)
// // {
// //     const int GRID_SIZE = 150;
// //     //scale is used to control how spread out our vertices
// //     HeightMap heightmap = HeightMap(width, height);
// //     float min_val = 10.0f;
// //     float max_val = 0.0f;
// //     foreach (x; 0 .. width)
// //     {
// //         foreach (z; 0 .. height)
// //         {
// //             float nx = (x + offsetX) * scale;
// //             float nz = (z + offsetZ) * scale;
// //             float val = 0.0f;
// //             for (int i = 0; i < 10; i++)
// //             {
// //                 //this will add multiple layers of noise to create a more complex terrain
// //                 //each layer will have a different scale and amplitude
// //                 float frequency = pow(2.0f, cast(float) i);
// //                 float amplitude = 20 * pow(0.5f, cast(float) i);
// //                 val += perlinNoise(nx * frequency / GRID_SIZE, nz * frequency / GRID_SIZE) * amplitude;
// //             }
// //             heightmap.y_vals[x][z] = val * 1.5; //height scaling
// //             if (heightmap.y_vals[x][z] > max_val)
// //             {
// //                 max_val = heightmap.y_vals[x][z];
// //             }
// //             if (heightmap.y_vals[x][z] < min_val)
// //             {
// //                 min_val = heightmap.y_vals[x][z];
// //             }
// //         }
// //     }
// //     saveHeightMapToPPM(heightmap, "./assets/heightmap.ppm");
// //     writefln("Heightmap generated with min value: %.2f, max value: %.2f", min_val, max_val);
// //     // debugHeightMap(heightmap);

// //     return heightmap;
// // }



// void debugHeightMap(HeightMap heightmap)
// {
//     writeln("===========================");
//     foreach (row; heightmap.y_vals)
//     {
//         foreach (value; row)
//         {
//             // writef("%f ", value);

//             writef("%.3f ", value);
//         }
//         writeln();
//     }
//     writeln("===========================");
// }
