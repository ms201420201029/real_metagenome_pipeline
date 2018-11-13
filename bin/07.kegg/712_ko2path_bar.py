import os,sys, argparse
import pandas as pd
from jinja2 import Environment, FileSystemLoader

def read_params(args):
    parser = argparse.ArgumentParser(description='''the number of ko in every pathway  | v1.0 huangyun''')
    parser.add_argument('-i', '--geneset_path', dest='geneset_path', metavar='FILE', type=str, required=True,
                        help="set geneset.path tab file")
    parser.add_argument('-g', '--diff_marker', dest='diff_marker', metavar='FILE', type=str, required=True,
                        help="set diff.marker.filt.tsv tab file")
    parser.add_argument("-l","--level",dest="level",metavar="level",type=int,required=True,
                        help="set level in 1,2,3 value")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    return vars(parser.parse_args())

if __name__ == '__main__':
    params = read_params(sys.argv)
    geneset_path = params["geneset_path"]
    diff_marker = params["diff_marker"]
    level = params["level"]
    out_dir = '%s/level_%s' % (params["out_dir"],params["level"])
    if not os.path.isdir(out_dir):
        os.system("mkdir -p %s" % out_dir)
    path2kos,kocount,columns_path,all_pathname = {},{},[],[]
    with open(geneset_path,"r") as fq:
        for line in fq:
            if line.strip().startswith("#"):
                continue
            tabs = line.strip().split("\t")
            if level == 1:
                pathname = tabs[3]
            if level == 2:
                pathname = tabs[4]
            if level == 3:
                pathname = tabs[0]
            kos = tabs[6].split("+")
            if pathname in all_pathname:
                kos = '%s\t%s' % ('\t'.join(path2kos[pathname]),'\t'.join(kos))
                path2kos[pathname] = kos.split('\t')
            else:
                path2kos[pathname] = kos
                all_pathname.append(pathname)
    with open(diff_marker,"r") as fq1:
        for line in fq1:
            if line.strip().startswith("taxonname"):
                continue
            tabs = line.strip().split("\t")
            ko_num = tabs[0]
            group_num = tabs[-1]
            if group_num not in kocount:
                kocount[group_num] = {}
            for path,value in path2kos.items():
                if ko_num in value:
                    if path not in columns_path:
                        columns_path.append(path)
                    kocount[group_num][path] = kocount[group_num][path]+1 if path in kocount[group_num] else 1
    df = pd.DataFrame(index=columns_path,columns=kocount.keys())
    for key,value in  kocount.items():
        for valkey,valval in value.items():
            df.loc[valkey,key]=valval
    df.fillna(0).to_csv("%s/kocount.txt"%out_dir,sep="\t")
    env = Environment(loader=FileSystemLoader("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/07.kegg/"),autoescape=False)
    template = env.get_template("712_ko2path.R")
    Rtext = template.render(kocuntfile="%s/kocount.txt"%out_dir,outdir = out_dir)
    with open(out_dir + '/712_ko2path.R', 'w') as fp:
        fp.write(Rtext)
    os.system("Rscript %s/712_ko2path.R"%out_dir)
    os.system("convert -density 300 %s/ko2path.pdf %s/ko2path.png"%(out_dir,out_dir))
