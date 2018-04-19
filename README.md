# Taller de mallas poligonales

## Propósito

Estudiar la relación entre las [aplicaciones de mallas poligonales](https://github.com/VisualComputing/representation), su modo de [representación](https://en.wikipedia.org/wiki/Polygon_mesh) (i.e., estructuras de datos empleadas para representar la malla en RAM) y su modo de [renderizado](https://processing.org/tutorials/pshape/) (i.e., modo de transferencia de la geometría a la GPU).

## Tareas

Hacer un benchmark (midiendo los *fps* promedio) de varias representaciones de mallas poligonales para los _boids_ del ejemplo del [FlockOfBoids](https://github.com/VisualComputing/framesjs/tree/processing/examples/Advanced/FlockOfBoids) (requiere la librería [frames](https://github.com/VisualComputing/framesjs/releases), versión ≥ 0.1.0), tanto en modo inmediato como retenido de rendering.

1. Represente la malla del [boid](https://github.com/VisualComputing/framesjs/blob/processing/examples/Advanced/FlockOfBoids/Boid.pde) al menos de ~tres~ dos formas distintas.
2. Renderice el _flock_ en modo inmediato y retenido, implementando la función ```render()``` del [boid](https://github.com/VisualComputing/framesjs/blob/processing/examples/Advanced/FlockOfBoids/Boid.pde).
3. Haga un benchmark que muestre una comparativa de los resultados obtenidos.

### Opcionales

1. Realice la comparativa para diferentes configuraciones de hardware.
2. Realice la comparativa de *fps* sobre una trayectoria de animación para el ojo empleando un [interpolator](https://github.com/VisualComputing/framesjs/tree/processing/examples/Basics/B8_Interpolation2) (en vez de tomar su promedio).
3. Anime la malla, como se hace en el ejemplo de [InteractiveFish](https://github.com/VisualComputing/framesjs/tree/processing/examples/ik/InteractiveFish).
4. Haga [view-frustum-culling](https://github.com/VisualComputing/framesjs/tree/processing/examples/Demos/ViewFrustumCulling) de los _boids_ cuando el ojo se encuentre en tercera persona.

### Profundizaciones

1. Introducir el rol depredador.
2. Cómo se afecta el comportamiento al tener en cuenta el [campo visual](https://es.wikipedia.org/wiki/Campo_visual) (individual)?
3. Implementar el algoritmo del ```flock()``` en [OpenCL](https://en.wikipedia.org/wiki/OpenCL). Ver [acá](https://www.youtube.com/watch?v=4NU37rPOAsk) un ejemplo de *Processing* en el que se que emplea [JOCL](http://www.jocl.org/).

### References

1. [Reynolds, C. W. Flocks, Herds and Schools: A Distributed Behavioral Model. 87](http://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/).
2. Check also this [nice presentation](https://pdfs.semanticscholar.org/73b1/5c60672971c44ef6304a39af19dc963cd0af.pdf) about the paper:
3. There are many online sources, google for more...

## Integrantes

Máximo 3.

Complete la tabla:


| Integrante | github nick |
|------------|-------------|
| Juan David Quintero      | [DavidQP](https://github.com/davidqp)            |
| Romain Fontaine          | [romainfontaine](https://github.com/romainfontaine)            |

## Resultados

Comparativo del desempeño, variando las representationes, los modos y las tecnicas de rendering.
El promedio de FPS se midió sobre un trayecto interpolado del ojo, con la malla del Boid dada en el ejemplo.


- La representation Face-Vertex es mas rapida porque tiene las faces estan representadas de una manera explicita.
- El modo retenido es mas lento porque el objeto renderizado es demasiado simple.
- El View Frustum Culling mejora un poco el desempeño en la mayoria de los casos.

Nota: Para obtener resultados mas interesantes, se podría comparar el desempeño con boids de complejidad mayor.

Medido en una maquina Intel Core I5-5200U, Intel HD Graphics 5500, 8GB RAM:
MeshRepresentation|Rendering Mode|Retained|ViewFrustumCulling|Average FPS
------------------|--------------|--------|------------------|-----------
Vertex-Vertex|Faces & Edges|true|true|21.360518
Vertex-Vertex|Faces & Edges|true|false|21.876698
Vertex-Vertex|Faces & Edges|false|true|27.970890
Vertex-Vertex|Faces & Edges|false|false|28.110529
Vertex-Vertex|Only Edges|true|true|27.249561
Vertex-Vertex|Only Edges|true|false|27.471605
Vertex-Vertex|Only Edges|false|true|28.867658
Vertex-Vertex|Only Edges|false|false|28.734300
Vertex-Vertex|Only Faces|true|true|25.619290
Vertex-Vertex|Only Faces|true|false|24.905601
Vertex-Vertex|Only Faces|false|true|30.883377
Vertex-Vertex|Only Faces|false|false|30.754749
Vertex-Vertex|Only Points|true|true|27.746189
Vertex-Vertex|Only Points|true|false|27.667632
Vertex-Vertex|Only Points|false|true|24.898156
Vertex-Vertex|Only Points|false|false|24.551680
Face-Vertex|Faces & Edges|true|true|22.413222
Face-Vertex|Faces & Edges|true|false|21.163909
Face-Vertex|Faces & Edges|false|true|28.422137
Face-Vertex|Faces & Edges|false|false|28.308351
Face-Vertex|Only Edges|true|true|27.303019
Face-Vertex|Only Edges|true|false|26.922592
Face-Vertex|Only Edges|false|true|29.744707
Face-Vertex|Only Edges|false|false|29.392267
Face-Vertex|Only Faces|true|true|24.095590
Face-Vertex|Only Faces|true|false|25.158441
Face-Vertex|Only Faces|false|true|30.595924
Face-Vertex|Only Faces|false|false|31.680746
Face-Vertex|Only Points|true|true|27.740002
Face-Vertex|Only Points|true|false|26.524441
Face-Vertex|Only Points|false|true|24.646514
Face-Vertex|Only Points|false|false|23.769648


Medido en una maquina Intel Core I3 3.77GHz, 8GB RAM:
MeshRepresentation|RenderMode|Retained|ViewFrustumCulling|AverageFPS
------------------|----------|--------|------------------|----------
Vertex-Vertex|Faces & Edges|true|true|31,945809
Vertex-Vertex|Faces & Edges|true|false|29,729801
Vertex-Vertex|Faces & Edges|false|true|38,207806
Vertex-Vertex|Faces & Edges|false|false|36,087166
Vertex-Vertex|Only Edges|true|true|39,150702
Vertex-Vertex|Only Edges|true|false|38,779029
Vertex-Vertex|Only Edges|false|true|38,827569
Vertex-Vertex|Only Edges|false|false|40,316894
Vertex-Vertex|Only Faces|true|true|38,193070
Vertex-Vertex|Only Faces|true|false|34,603673
Vertex-Vertex|Only Faces|false|true|38,267334
Vertex-Vertex|Only Faces|false|false|40,377155
Vertex-Vertex|Only Points|true|true|36,794101
Vertex-Vertex|Only Points|true|false|38,662383
Vertex-Vertex|Only Points|false|true|32,288518
Vertex-Vertex|Only Points|false|false|29,274063
Face-Vertex|Faces & Edges|true|true|34,336980
Face-Vertex|Faces & Edges|true|false|30,708076
Face-Vertex|Faces & Edges|false|true|40,371567
Face-Vertex|Faces & Edges|false|false|36,896587
Face-Vertex|Only Edges|true|true|38,615692
Face-Vertex|Only Edges|true|false|37,903409
Face-Vertex|Only Edges|false|true|41,402560
Face-Vertex|Only Edges|false|false|39,089708
Face-Vertex|Only Faces|true|true|35,944432
Face-Vertex|Only Faces|true|false|35,130075
Face-Vertex|Only Faces|false|true|42,405147
Face-Vertex|Only Faces|false|false|43,525593
Face-Vertex|Only Points|true|true|33,523111
Face-Vertex|Only Points|true|false|36,476432
Face-Vertex|Only Points|false|true|30,631610
Face-Vertex|Only Points|false|false|26,520298


## Entrega

* Modo de entrega: Haga [fork](https://help.github.com/articles/fork-a-repo/) de la plantilla e informe la url del repo en la hoja *urls* de la plantilla compartida (una sola vez por grupo). Plazo: 15/4/18 a las 24h.
* Exposición oral en el taller de la siguiente semana (6 minutos: 4 para presentar y 2 para preguntas). Estructura sugerida:
  1. Representaciones estudiadas.
  2. Demo.
  3. Resultados (benchmark).
  4. Conclusiones.
