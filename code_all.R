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

for(file_name in file_names){
  print('=====')
  print(file_name)
  print('=====')
  source("code.R")
}
print('finish!')
