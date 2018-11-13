#merge_metaphlan_tables.py ../abundance/*_profile.txt | sed 's/.profile//g' > merged_metaphlan3.txt
#sed -i '2d' merged_metaphlan2.txt
cp merged_metaphlan3.txt all.profile
for i in {1..8} ;do echo '# Constructed from biom file' >otu_table_L${i}.txt ;done
for i in {1..8} ;do head -1 all.profile >>otu_table_L${i}.txt ;done
for i in {1..8} ;do sed -i '2s/^/#OTU /' otu_table_L${i}.txt ;done
grep -Poh "k__\w+\t.*" all.profile >>otu_table_L1.txt
grep -Poh "p__\w+\t.*" all.profile >>otu_table_L2.txt
grep -Poh "c__\w+\t.*" all.profile >>otu_table_L3.txt
grep -Poh "o__\w+\t.*" all.profile >>otu_table_L4.txt
grep -Poh "f__\w+\t.*" all.profile >>otu_table_L5.txt
grep -Poh "g__\w+\t.*" all.profile >>otu_table_L6.txt
grep -Poh "s__\w+\t.*" all.profile >>otu_table_L7.txt
grep -Poh "t__\w+\t.*" all.profile >>otu_table_L8.txt
head -1 all.profile >kind.profile
head -1 all.profile >phylum.profile
head -1 all.profile >class.profile
head -1 all.profile >order.profile
head -1 all.profile >family.profile
head -1 all.profile >genus.profile
head -1 all.profile >species.profile
head -1 all.profile >strain.profile
grep  -Poh "k__\w+\t.*" all.profile >>kind.profile
grep  -Poh "p__\w+\t.*" all.profile >>phylum.profile
grep  -Poh "c__\w+\t.*" all.profile >>class.profile
grep  -Poh "o__\w+\t.*" all.profile >>order.profile
grep  -Poh "f__\w+\t.*" all.profile >>family.profile
grep  -Poh "g__\w+\t.*" all.profile >>genus.profile
grep  -Poh "s__\w+\t.*" all.profile >>species.profile
grep  -Poh "t__\w+\t.*" all.profile >>strain.profile

