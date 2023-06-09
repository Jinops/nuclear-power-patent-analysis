file_names <- list(
  'G21B',
  'G21C',
  'G21D',
  'G21F',
  'G21G',
  'G21H',
  'G21J',
  'G21K'
)
file_names <- append(file_names, 'All')

# Registrations
for(file_name_loop in file_names){
  print('=====')
  print(file_name_loop)
  print('=====')
  source("00_run_regist.R")
}
print('finish! - Registrations')

# Applications
for(file_name_loop in file_names){
  print('=====')
  print(file_name_loop)
  print('=====')
  source("00_run_app.R")
}
print('finish! - Applications')

rm(file_name_loop)
