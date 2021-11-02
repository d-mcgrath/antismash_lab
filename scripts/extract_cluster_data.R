# load required libraries
invisible(lapply(c('dplyr', 'optparse'),
                 library, character.only = TRUE, quietly = T, warn.conflicts = FALSE))


#parse command line arguments
option_list = list(
  make_option(c('-i', '--input-dir'), action = 'store',
              help = 'The path of the directory containing input file(s) [default: .]',
              type = 'character',
              default = '.'),

  make_option(c('-p', '--pattern'), action = 'store',
              help = 'The file extension regex pattern of input file(s) [default: .*region.*.gbk]',
              type = 'character',
              default = '.*region.*.gbk'),

  make_option(c('-o', '--output-dir'), action = 'store',
              help = 'The path of the directory to save results to [default: .]',
              type = 'character',
              default = '.'),

  make_option(c('-r', '--recursive'), action = 'store',
              help = 'Should all folders in the current directory be recursively searched for Genbank cluster files? (TRUE/FALSE) [default: FALSE]',
              type = 'logical',
              default = FALSE)
)

argv = parse_args(OptionParser(option_list = option_list))


#save filepaths and filenames of input genbank files
filepaths = list.files(argv$`input-dir`,
                    pattern = argv$pattern,
                    full.names = TRUE,
                    recursive = argv$recursive)

filenames = stringr::str_replace(filepaths, '.*\\/+(.*region.*)', '\\1')


#message to say what files are being processed
cli::cli_alert_info('Processing the cluster files from directory: {argv$`input-dir`}')


## function to parse genbank files
parse_genbank = function(filepath, filename) {
  genbank = genbankr::parseGenBank(filepath)

  genbank = genbank$FEATURES %>%
    purrr::map_dfr(~ .x) %>%
    mutate(contig = genbank$ACCESSION,
           filename = filename,
           filepath = filepath) %>%
    relocate(c(filepath, filename, contig, product), .before = 1)

  return(genbank)
}


# create result and summary objects
full_results = purrr::map2_dfr(filepaths, filenames, ~ parse_genbank(.x, .y))

summary = full_results %>%
  filter(type == 'protocluster') %>%
  select(product, contig, start, end,
         core_location, detection_rule,
         filename, filepath)


# save the results and summary objects in flatfiles
outdir <- argv$`output-dir`
if (!stringr::str_detect(outdir, '.*\\/$')) {
  outdir <- stringr::str_replace(outdir, '(.*)', '\\1\\/')
}

purrr::walk2(list(full_results, summary),
      c('cluster_full_results', 'cluster_summary'),
      ~ readr::write_tsv(.x, file = paste0(outdir, .y, '.tsv'))
)


#message to notify that the script ran successfully
cli::cli_alert_success('All done.')

