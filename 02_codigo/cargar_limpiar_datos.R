### Paquetes ----
library(pacman)
p_load(classInt, lubridate, ggraph, ggwordcloud, igraph, readxl, rvest, scales, syuzhet, tidytext, tidyverse, tm, udpipe, WriteXLS, xml2)


### Setup general ----
Sys.setlocale("LC_ALL", "es_ES.UTF-8") 
options(scipen = 9999)
theme_set(theme_gray())

## Definir tema de gráficas ----
tema <-  theme_minimal() +
  theme(text = element_text(family = "Didact Gothic Regular", color = "grey35"),
        plot.title = element_text(size = 28, face = "bold", margin = margin(10,0,20,0), family = "Trebuchet MS Bold", color = "grey25"),
        plot.subtitle = element_text(size = 16, face = "bold", colour = "#666666", margin = margin(0, 0, 20, 0), family = "Didact Gothic Regular"),
        plot.caption = element_text(hjust = 0, size = 15),
        panel.grid = element_line(linetype = 2), 
        panel.grid.minor = element_blank(),
        legend.position = "bottom",
        legend.title = element_text(size = 16, face = "bold", family = "Trebuchet MS Bold"),
        legend.text = element_text(size = 14, family = "Didact Gothic Regular"),
        legend.title.align = 0.5,
        axis.title = element_text(size = 18, hjust = 1, face = "bold", margin = margin(0,0,0,0), family = "Didact Gothic Regular"),
        axis.text = element_text(size = 16, face = "bold", family = "Didact Gothic Regular"))

### Importar discursos de AMLO ----

# Definir URLs que contienen los discursos ----

url_disc_amlo <-
  tibble(url = c("https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-de-los-estados-unidos-mexicanos-andres-manuel-lopez-obrador",
                 "https://www.gob.mx/presidencia/es/articulos/discurso-de-andres-manuel-lopez-obrador-presidente-de-los-estados-unidos-mexicanos",
                 "https://www.gob.mx/presidencia/es/articulos/palabras-del-presidente-andres-manuel-lopez-obrador-durante-la-firma-del-decreto-presidencial-para-la-verdad-en-el-caso-ayotzinapa",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-presentacion-del-programa-nacional-de-electricidad",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-de-plan-nacional-de-refinacion", 
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-entrega-de-premio-nacional-de-derechos-humanos",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-del-programa-nacional-de-reconstruccion", 
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-presentacion-del-plan-nacional-para-produccion-de-hidrocarburos",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-ceremonia-de-pueblos-originarios-para-construccion-del-trenmaya",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-encuentro-para-construccion-de-paz-y-seguridad",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-de-la-nueva-politica-de-salarios-minimos",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-del-programa-universidades-para-el-bienestar-benito-juarez-garcia",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-de-programa-nacional-de-los-pueblos-indigenas",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-presentacion-de-programa-de-pavimentacion-de-caminos-a-cabeceras-municipales",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-presentacion-del-programa-nacional-de-infraestructura-carretera",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-del-plan-de-desarrollo-del-istmo-de-tehuantepec",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-supervision-de-la-linea-12-del-metro",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-presentacion-de-programas-integrales-de-desarrollo-para-la-laguna",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-del-programa-de-la-secretaria-de-economia",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-inauguracion-de-oficinas-del-imss-y-presentacion-de-plan-imss-2018-2024",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-inicio-del-programa-zona-libre-de-la-frontera-norte",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-del-programa-zona-libre-de-la-frontera-norte-en-chihuahua",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-del-programa-zona-libre-de-la-frontera-norte-en-tijuana",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-presentacion-de-programa-de-impulso-al-sector-financiero",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-xxx-reunion-con-embajadores-y-consules",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-arranque-del-programa-jovenes-construyendo-el-futuro",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-presentacion-de-la-pension-para-el-bienestar-de-las-personas-con-discapacidad",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-homenaje-a-emiliano-zapata-por-el-centenario-de-su-asesinato",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-presentacion-de-la-pension-para-el-bienestar-de-las-personas-adultas-mayores",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-programas-integrales-de-desarrollo",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-de-los-precios-de-garantia-para-granos-basicos",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-presentacion-de-programas-para-el-desarrollo-en-acambay",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-programas-integrales-de-desarrollo-en-ixtlahuaca",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-de-los-programas-integrales-de-desarrollo-en-puebla",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-presentacion-de-programas-integrales-de-desarrollo-en-hidalgo",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-iii-sesion-extraordinaria-del-consejo-nacional-de-seguridad-publica",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-atencion-integral-para-afectados-de-huracan-willa-en-tuxpan-nayarit",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-tecuala-nayarit-para-la-atencion-integral-de-damnificados-por-huracan-willa",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-rosario-sinaloa-para-supervisar-los-avances-de-la-obra-de-la-presa-santa-maria",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-culiacan-sinaloa-sobre-los-programas-integrales-de-desarrollo",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-culiacan-sinaloa-para-presentar-la-estrategia-nacional-de-lectura",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-guasave-sinaloa-durante-el-recorrido-en-el-estadio-francisco-carranza-limon",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-de-la-canasta-basica",
                 
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-evento-hacia-basura-cero-en-minatitlan",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-el-inicio-de-sembrando-vida-en-acayucan",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-de-sembrando-vida-en-cordoba",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-conmemoracion-del-102-aniversario-de-la-constitucion-de-1917",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-becas-bienestar-para-las-familias-en-iguala",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-apoyos-produccion-para-el-bienestar",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-inicio-del-programa-nacional-de-fertilizantes",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-106-aniversario-de-la-marcha-de-la-lealtad",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-becas-benito-juarez-educacion-media-superior", 
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-el-dia-de-la-fuerza-aerea-mexicana",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-cuautla-morelos",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-entrega-de-becas-jovenes-escribiendo-el-futuro",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-firma-firma-del-acuerdo-marco-entre-el-gobierno-de-mexico-y-la-unops",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-supervision-de-tramo-carretero-en-badiraguato-sinaloa",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-supervision-del-tramo-carretero-en-tamazula-durango",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-su-visita-a-mazatlan-sinaloa",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-su-visita-a-el-salto-durango",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-lopez-obrador-durante-presentacion-del-consejo-para-el-fomento-a-la-inversion-el-empleo-y-el-crecimiento-economico", 
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-consejo-mexicano-de-negocios?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-conmemoracion-del-dia-del-ejercito-mexicano?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-inauguracion-del-salon-de-la-fama-del-beisbol-mexicano?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-el-106-aniversario-luctuoso-de-francisco-i-madero?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-credito-ganadero-a-la-palabra?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-entrega-de-creditos-ganaderos-en-chiapas?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-candelaria-campeche-durante-entrega-de-creditos-ganaderos-a-la-palabra?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-escarcega-durante-entrega-de-creditos-ganaderos-a-la-palabra?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-conmemoracion-del-dia-de-la-bandera-nacional-en-chetumal?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/palabras-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-de-la-estrategia-nacional-de-turismo?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-xxxvi-asamblea-anual-ordinaria-del-consejo-coordinador-empresarial?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-tandas-para-el-bienestar-en-chihuahua?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-entrega-de-programas-y-tandas-para-el-bienestar-en-sonora?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-el-programa-de-mejoramiento-urbano?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-programas-integrales-de-bienestar-en-manzanillo?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-evento-mujeres-transformando-mexico?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-la-entrega-de-programas-de-bienestar-en-aguascalientes?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-programas-integrales-de-bienestar-en-guanajuato?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-precios-de-garantia-en-encarnacion-de-diaz-jalisco?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-de-los-programas-integrales-de-bienestar-en-guadalajara?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-programas-bienestar-en-puebla-puebla?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-en-el-informe-de-los-primeros-100-dias-de-gobierno?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-clausura-del-foro-nacional-planeando-juntos-la-transformacion-de-mexico?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-conmemoracion-del-81-aniversario-de-la-expropiacion-petrolera?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-el-213-aniversario-del-natalicio-de-benito-juarez?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-clausura-de-la-82-convencion-bancaria?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-presentacion-del-programa-de-mejoramiento-urbano?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-inauguracion-del-estadio-de-los-diablos-rojos-del-mexico-alfredo-harp-helu?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-de-mexico-andres-manuel-lopez-obrador-durante-la-reinstalacion-del-sistema-nacional-de-busqueda-de-personas?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-de-mexico-andres-manuel-lopez-obrador-durante-la-ceremonia-conmemorativa-por-los-500-anos-de-la-batalla-de-centla?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/mensaje-del-presidente-andres-manuel-lopez-obrador-durante-la-entrega-de-programas-de-la-frontera-norte-y-mejoramiento-urbano?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/presidente-andres-manuel-lopez-obrador-entrega-programas-para-el-bienestar-en-poza-rica?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/presidente-andres-manuel-lopez-obrador-encabeza-la-entrega-de-programas-integrales-de-bienestar-en-tuxpan?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/presidente-andres-manuel-lopez-obrador-presenta-los-programas-integrales-de-bienestar-en-tantoyuca?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/presidente-andres-manuel-lopez-obrador-presenta-los-programas-integrales-de-bienestar-en-huejutla?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/presidente-andres-manuel-lopez-obrador-presenta-el-sistema-de-universidades-benito-juarez-en-san-luis-potosi?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/presidente-andres-manuel-lopez-obrador-hace-entrega-de-los-programas-bienestar-en-san-luis-potosi?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-zacapu?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-uruapan?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-morelia?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-el-tianguis-turistico-acapulco-2019?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-la-entrega-de-programas-bienestar?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-la-entrega-de-programas-bienestar-de-hopelchen?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-la-entrega-de-programas-bienestar-en-campeche-campeche?idiom=es",
                 "https://www.gob.mx/presidencia/es/articulos/version-estenografica-del-presidente-lopez-obrador-en-la-entrega-de-programas-bienestar-en-champoton-campeche?idiom=es"))

# Extraer discursos ----
discursos_amlo <- 
  url_disc_amlo %>% 
  mutate(cuerpo = map(.x = url,
                      .f = ~ read_html(.) %>% 
                        html_nodes(".article-body")))  

discursos_amlo <- 
  discursos_amlo %>%
  mutate(texto = map_chr(cuerpo, ~ html_nodes(.x, "p") %>%
                           html_text() %>%
                           paste0(collapse = " ")))

# Extraer fechas de discursos ----
fechas_discursos <- 
  url_disc_amlo %>% 
  mutate(fecha = map(.x = url,
                     .f = ~ read_html(.) %>% 
                       html_nodes(".border-box")))

fechas_discursos <- 
  fechas_discursos %>% 
  mutate(fecha = map_chr(fecha, ~ html_nodes(.x, "dd") %>%
                           html_text() %>%
                           paste0(collapse = " ")),
         fecha = str_replace(fecha, "Presidencia de la República  ", "")) # Limpiar fechas eliminando la cadena de texto "Presidencia de la República  " de las mismas


# Extraer títulos de discursos ----
titulos_discursos <- 
  url_disc_amlo %>% 
  mutate(titulo = map(.x = url,
                      .f = ~ read_html(.) %>% 
                        html_nodes("title") %>% 
                        html_text()))

# Cambiar tipo y limpiar columna de titulo 
titulos_discursos <- 
  titulos_discursos %>% 
  mutate(titulo = unlist(titulo), 
         titulo = str_replace_all(titulo, "\\n", ""),
         titulo = str_trim(titulo))

# Unir datos en un solo data frame ----
discursos_amlo <- 
  discursos_amlo %>% 
  left_join(fechas_discursos) %>% 
  left_join(titulos_discursos) %>% 
  select(fecha, titulo, texto, url, -cuerpo)


# Generar columna con id númerico por discurso ----
discursos_amlo <- 
  discursos_amlo %>% 
  mutate(discurso_id = row_number()) %>% 
  select(discurso_id, everything())


# Elimiar palabras no mencionadas por AMLO en sus eventos ----

# En diversos eventos participan otros oradores (e.g., militares respondiendo a coro al presidente, moderadores presentándolo, personas en el público que le hacen preguntas, funcionarios públicos, etc.). El siguiente chunk de código permite eliminar las palabras dichas por oradores direrentes a AMLO que pudimos detectar.

discursos_amlo <- 
  discursos_amlo %>% 
  mutate(texto = str_replace(texto, "VOCES A CORO:.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 
         texto = str_replace(texto, "MODERADOR: Presiden la III Sesión Extraordinaria.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en los renglones con id 36
         texto = str_replace(texto, "Santa Lucía, Estado de México, 10 de febrero de 2019 Celebración.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 53
         texto = str_replace(texto, "Cuautla, Morelos, 10 de febrero de 2019 Propuesta del gobierno federal: .*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 54
         texto = str_replace(texto, "INTERVENCIÓN:.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 18 
         texto = str_replace(texto, "JOVEN:.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 32 
         texto = str_replace(texto, "Versión estenográfica Tamazula, Durango, 16 de.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 58
         texto = str_replace(texto, "Versión estenográfica Mazatlán, Sinaloa, 16 de febrero de 2019.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 59
         texto = str_replace(texto, "VE-157 Versión estenográfica Chihuahua, Chihuahua, 2 de marzo de 2019.*PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR:", ""), # Eliminar palabras que no corresponde a AMLO en el renglón con id 73
         texto = str_replace(texto, "PRESIDENTE ANDRÉS MANUEL LÓPEZ OBRADOR: Amigas", "Amigas") # Eliminar palabras que no corresponde a AMLO en los renglones con id 39, 40, 41 y 42
  )


# Generar archivo .xls con los discursos de AMLO ----
WriteXLS(discursos_amlo, ExcelFileName = "04_datos_output/discursos_amlo.xls",
         Encoding = c("UTF-8"))