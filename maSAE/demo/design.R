library('maSAE')
message('## load data')
data('s2')
message('## create object')
saeO  <- saObj(data = s2, f = y ~ NULL | g)
message('## design-based estimation for all small areas given by g')
predict(saeO)
message('## again, assuming the data are clustered:')
saeO  <- saObj(data = s2, f = y ~ NULL | g, cluster = 'clustid')
message('## as expected, the variances disregarding the clusters were deflated:')
predict(saeO)
