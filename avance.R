install.packages("DBI")
install.packages("RMySQL")

library(DBI)
library(RMySQL)

con <- dbConnect(
  RMySQL::MySQL(),
  host = "database-1.cnoykiegme2i.us-east-1.rds.amazonaws.com",
  port = 3306,
  user = "admin",
  password = "admin123*123"
)

# Crear la base de datos
dbExecute(con, "CREATE DATABASE accidentes")

dbDisconnect(con)

con <- dbConnect(
  RMySQL::MySQL(),
  dbname = "accidentes",  
  host = "database-1.cnoykiegme2i.us-east-1.rds.amazonaws.com",
  port = 3306,
  user = "admin",
  password = "admin123*123"
)

# Verificar conexión
dbListTables(con)

#Crear Tabla
query_crear_tabla <- "
CREATE TABLE accidentes (
    fecha DATE,
    hora TIME,
    ubicacion VARCHAR(50),
    tipo_accidente VARCHAR(50),
    condiciones_climaticas VARCHAR(50),
    vehiculos_involucrados INT,
    edad_victima INT,
    genero_victima CHAR(1),
    lesion VARCHAR(50)
);
"
dbExecute(con, query_crear_tabla)

# Leer el archivo CSV
accidentes <- read.csv("Trabajo Final/accidentes F.csv")

# Insertar datos en la tabla
dbWriteTable(con, name = "accidentes", value = accidentes, row.names = FALSE, append = TRUE)

# Verificar el número de registros en la tabla
dbGetQuery(con, "SELECT COUNT(*) AS total FROM accidentes")

# Consulta básica de los primeros registros
datos <- dbGetQuery(con, "SELECT * FROM accidentes LIMIT 10")
print(datos)

# Identificar valores faltantes
sapply(accidentes, function(x) sum(is.na(x)))

# Imputar valores faltantes en "edad_victima" con la media
accidentes$edad_victima[is.na(accidentes$edad_victima)] <- mean(accidentes$edad_victima, na.rm = TRUE)

# Boxplot para detectar valores atípicos
boxplot(accidentes$vehiculos_involucrados, main = "Vehiculos Involucrados", ylab = "Cantidad")

# Eliminar valores extremos
accidentes <- accidentes[accidentes$vehiculos_involucrados <= 4, ]

install.packages("ggplot2")
library(ggplot2)

# Visualizar accidentes por tipo
ggplot(accidentes, aes(x = tipo_accidente)) +
  geom_bar(fill = "blue") +
  labs(title = "Tipos de Accidentes", x = "Tipo de Accidente", y = "Frecuencia")






#Reporte Shiny
install.packages("shiny")
library(shiny)

ui <- fluidPage(
  titlePanel("Reporte de Accidentes"),
  sidebarLayout(
    sidebarPanel(
      selectInput("ubicacion", "Ubicacion:", choices = unique(accidentes$ubicacion))
    ),
    mainPanel(
      plotOutput("plot_accidentes")
    )
  )
)

server <- function(input, output) {
  output$plot_accidentes <- renderPlot({
    filtro <- subset(accidentes, ubicacion == input$ubicacion)
    ggplot(filtro, aes(x = tipo_accidente)) +
      geom_bar(fill = "orange") +
      labs(title = paste("Accidentes en", input$ubicacion), x = "Tipo de Accidente", y = "Frecuencia")
  })
}

shinyApp(ui = ui, server = server)

install.packages("rsconnect")
