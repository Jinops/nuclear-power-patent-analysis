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

for(file_name_loop in file_names){
  print('=====')
  print(file_name_loop)
  print('=====')
  source("run_regist.R")
  #source("run_app.R")
}
print('finish!')