from ete3 import Tree, TreeStyle, NodeStyle, TextFace
import sys
tree_fh     = open(sys.argv[1])
tree_newick = tree_fh.read()
tree_ete    = Tree(tree_newick, format = 1)

node_fh = open(sys.argv[2])
color = {}
size  = {}
value = {}
node_info = node_fh.readlines()
for info in node_info:
    info  = info.rstrip('\n')
    infos = list(info.split('\t'))
    color[infos[0]] = infos[1]
    size[infos[0]] = infos[2]
    value[infos[0]] = "%.2f %%" % (float(infos[3]) * 100)

tstyle = TreeStyle()
tstyle.complete_branch_lines_when_necessary = False
tstyle.show_leaf_name = False
tstyle.scale = 1
tstyle.branch_vertical_margin = 40
tstyle.show_scale = False
tree_ete.set_style(tstyle)

for node in tree_ete.traverse() :
    if node.name != "root" :
        name_face = TextFace(node.name)
        abun_face = TextFace(value[node.name])
        node.add_face(name_face, column = 0, position = "branch-top")
        node.add_face(abun_face, column = 0, position = "branch-bottom")
        nstyle            = NodeStyle()
        nstyle["fgcolor"] = color[node.name]
        nstyle["size"]    = float(size[node.name])
        node.set_style(nstyle)
    else :
        nstyle = NodeStyle()
        nstyle["fgcolor"] = "white"
        nstyle["bgcolor"] = "white"
        nstyle["vt_line_color"] = "white"
        nstyle["hz_line_color"] = "white"
        node.set_style(nstyle)
tree_ete.render(sys.argv[3], tree_style = tstyle)
