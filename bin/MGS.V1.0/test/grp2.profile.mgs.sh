Rscript ../Rscript/2.0_4.0_fast_2_markers_groups.r H.profile 0.8 complete
Rscript ../Rscript/3.0_get_average_groups.r group_H.profile H.profile 100 25
Rscript ../Rscript/2.0_4.0_fast_2_markers_groups.r group_mean_H.profile 0.9 complete
Rscript ../Rscript/5.0_second_groups.r group_H.profile group_group_mean_H.profile
Rscript ../Rscript/6.0_second_best.r second_groups_H.profile H.profile 25
