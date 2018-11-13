var mrpps = [
    {% for key,mrppAnalysis in mrpp.items() %}
        {
            Group:"{{ mrppAnalysis.group }}",
            A:"{{ mrppAnalysis.a }}",
            ObserveDelta:"{{ mrppAnalysis.observeDelta }}",
            ExpectDelta:"{{ mrppAnalysis.expectDelta }}",
            Significance:"{{ mrppAnalysis.significance }}"
        },

    {% endfor %}
];
$(function () {
    $('#toolbar14').find('select').change(function () {
        $('#table14').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table14').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'Group',
        title: 'Group',
        align: 'center',
        sortable: true,
        filterControl: 'select',
    }, {
        field: 'A',
        title: 'A',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'ObserveDelta',
        title: 'ObserveDelta',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'ExpectDelta',
        title: 'ExpectDelta',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'Significance',
        title: 'Significance',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: mrpps
});


var lengths = [
    {% for key,readsLength in readsLengths.items() %}
        {
            length_name:"{{ readsLength.name }}",
            num:"{{ readsLength.num }}"
        },

    {% endfor %}
];
$(function () {
    $('#toolbar13').find('select').change(function () {
        $('#table13').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table13').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'length_name',
        title: 'Length (bp)',
        align: 'center',
        sortable: true,
        filterControl: 'select',
    }, {
        field: 'num',
        title: 'Sequences',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: lengths
});


var Stat = [
    {% for key,readsStat in readsStats.items() %}
        {
            sampleName:"{{ readsStat.sampleName }}",
            cleanReads:"{{ readsStat.clean_read }}",
            Bases:"{{ readsStat.base }}",
            Q20:"{{ readsStat.q20 }}",
            Q30:"{{ readsStat.q30 }}",
            GC:"{{ readsStat.gc }}",
            averageLength:"{{ readsStat.average_length }}"
        },

    {% endfor %}
];

$(function () {
    $('#toolbar12').find('select').change(function () {
        $('#table12').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table12').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'sampleName',
        title: 'Sample name',
        align: 'center',
        sortable: true,
        filterControl: 'select',
    }, {
        field: 'cleanReads',
        title: 'clean reads',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'Bases',
        title: 'Bases(bp)',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'Q20',
        title: 'Q20(%)',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'Q30',
        title: 'Q30(%)',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'GC',
        title: 'GC(%)',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'averageLength',
        title: 'Average Length',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: Stat
});


// JavaScript Document
var dataStatisticals = [
	{% for key,otuStatistical in otuStatisticals %}
		{
			sampleName:"{{ otuStatistical.sampleName|safe }}",
			ampliconType:"{{ otuStatistical.amplicon_type }}",
			cleanReads:"{{ otuStatistical.clean_read }}",
			mappedReads:"{{ otuStatistical.mapped_reads }}",
			mappedRatio:"{{ otuStatistical.mapped_ratio }}",
			OTUs:"{{ otuStatistical.otus }}"
		},
	{% endfor %}
	];

$(function () {
    $('#toolbar1').find('select').change(function () {
        $('#table1').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table1').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'sampleName',
        title: 'Sample name',
        align: 'center',
        sortable: true,
        filterControl: 'select',
    }, {
        field: 'ampliconType',
        title: 'Amplicon type',
        align: 'center',
        filterControl: 'select',
        sortable: true,
    }, {
        field: 'cleanReads',
        title: 'clean reads',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'mappedReads',
        title: 'mapped reads',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'mappedRatio',
        title: 'mapped reads(%)',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'OTUs',
        title: 'OTUs',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: dataStatisticals
});



/* otuStatistical */
var otuStatisticalDownsizes=[

 {% for key,otuStatisticalDownsize in otuStatisticalDownsizes %}

 {
	 sampleName:"{{ otuStatisticalDownsize.sample_name|safe }}",
	 downsize:"{{ otuStatisticalDownsize.downsize }}",
	 otus_before:"{{ otuStatisticalDownsize.otus_before }}",
	 otus_after:"{{ otuStatisticalDownsize.otus_after }}"
 },
	{% endfor %}
];

$(function () {
    $('#toolbar2').find('select').change(function () {
        $('#table2').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table2').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'sampleName',
        title: 'Sample name',
        align: 'center',
        sortable: true,
        filterControl: 'input',
    }, {
        field: 'downsize',
        title: 'downsize',
        align: 'center',
        filterControl: 'select',
        sortable: true,
    }, {
        field: 'otus_before',
        title: 'otus before',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'otus_after',
        title: 'otus after',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: otuStatisticalDownsizes
});



/*coreMicrobiomes*/
var coreMicrobiomes=[

 {% for key,coreMicrobiome in coreMicrobiomes.items() %}

 {
	 otuId:"{{ coreMicrobiome.otu_id|safe }}",
	 taxonomyLevel:"{{ coreMicrobiome.taxonomy_level|safe }}",
	 taxonomyName:"{{ coreMicrobiome.taxonomy_name|safe }}"
 },
	{% endfor %}
];

$(function () {
    $('#toolbar3').find('select').change(function () {
        $('#table3').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table3').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'otuId',
        title: 'otuName',
        align: 'center',
        sortable: true,
        filterControl: 'input',
    }, {
        field: 'taxonomyLevel',
        title: 'taxonomyLevel',
        align: 'center',
        filterControl: 'select',
        sortable: true,
    }, {
        field: 'taxonomyName',
        title: 'taxonomyName',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: coreMicrobiomes
});


/*otuAssignmentsStatisticals*/
var otuAssignmentsStatisticals=[

    {% for  key,otuAssignmentsStatistical in otuAssignmentsStatisticals.items() %}

	{
		otuName:"{{ key }}",
		num:"{{ otuAssignmentsStatistical.num }}"
    },

	{% endfor %}
];
$(function () {
    $('#toolbar4').find('select').change(function () {
        $('#table4').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table4').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'otuName',
        title: 'otuName',
        align: 'center',
        sortable: true,
        filterControl: 'input',
    }, {
        field: 'num',
        title: 'num',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: otuAssignmentsStatisticals
});


/*alpha_diversitys*/
var alpha_diversitys=[

 {% for key,alphaDiversity in alpha_diversitys.items() %}

{
    sampleName:"{{ alphaDiversity.alphaName|safe }}",
    chao1:"{{ alphaDiversity.chao1 }}",
    goodsCoverage:"{{ alphaDiversity.goods_coverage }}",
    observedSpecies:"{{ alphaDiversity.observed_species }}",
    wholeTree:"{{ alphaDiversity.whole_tree }}",
    shannon:"{{ alphaDiversity.shannon }}",
    simpson:"{{ alphaDiversity.simpson }}"
},
	{% endfor %}
];

$(function () {
    $('#toolbar5').find('select').change(function () {
        $('#table5').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table5').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'sampleName',
        title: 'sampleName',
        align: 'center',
        sortable: true,
        filterControl: 'input',
    }, {
        field: 'chao1',
        title: 'chao1',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    },  {
        field: 'observedSpecies',
        title: 'observedSpecies',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'wholeTree',
        title: 'PD-wholeTree',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'shannon',
        title: 'shannon',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'simpson',
        title: 'simpson',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    },{
        field: 'goodsCoverage',
        title: 'goodsCoverage',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: alpha_diversitys
});



/*alpha_diversity_diffs*/

{% if alpha_diff_exist %}
var alpha_diversity_diffs=[

{% for key,alphaDiversity in alpha_diversity_diffs.items() %}

{
    sampleName:"{{ alphaDiversity.alphaName|safe}}",
        chao1:"{{ alphaDiversity.chao1 }}",
    goodsCoverage:"{{ alphaDiversity.goods_coverage }}",
    observedSpecies:"{{ alphaDiversity.observed_species }}",
    wholeTree:"{{ alphaDiversity.whole_tree }}",
    shannon:"{{ alphaDiversity.shannon }}",
    simpson:"{{ alphaDiversity.simpson }}"
},
	{% endfor %}
];


$(function () {
    $('#toolbar6').find('select').change(function () {
        $('#table6').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table6').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, {
        field: 'sampleName',
        title: 'sampleName',
        align: 'center',
        sortable: true,
        filterControl: 'input',
    }, {
        field: 'chao1',
        title: 'chao1',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'observedSpecies',
        title: 'observedSpecies',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'wholeTree',
        title: 'PD-wholeTree',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'shannon',
        title: 'shannon',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'simpson',
        title: 'simpson',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }, {
        field: 'goodsCoverage',
        title: 'goodsCoverage',
        align: 'center',
        filterControl: 'input',
        sortable: true,
    }],
    data: alpha_diversity_diffs
});

{% endif %}



/*beta_diversitys*/
{% if beta_diversity_exist %}
var beta_diversitys=[
    {% for beta_diversity in beta_diversity_data %}
        {{ beta_diversity }}
    {% endfor %}
];

$(function () {
    $('#toolbar7').find('select').change(function () {
        $('#table7').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table7').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    },	
	{% for beta_diversity in beta_diversity_jqGrid %}
	{{ beta_diversity }}
	{% endfor %}

    ],
    data: beta_diversitys
});

{% endif %}


/*beta_un_diversitys*/

{% if beta_un_diversity_exist %}
 var beta_un_diversitys=[
 {% for beta_diversity in beta_un_diversity_data %}
 {{ beta_diversity }}
	{% endfor %}
 ];

$(function () {
    $('#toolbar8').find('select').change(function () {
        $('#table8').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table8').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    },
    {% for beta_diversity in beta_un_diversity_jqGrid %}
		{{ beta_diversity }}
	{% endfor %}

	],
    data: beta_un_diversitys
});
 {% endif %}


/*diff_otu_markers*/
{% if diff_otu_marker_exist %}
var diff_otu_markers=[
 {% for value in diff_otu_marker_data %}
 {{ value }}
	{% endfor %}
 ];

$(function () {
    $('#toolbar9').find('select').change(function () {
        $('#table9').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table9').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, 
	{% for value in diff_otu_marker_jqGrid %}
		{{ value }}
	{% endfor %}
    ],
    data: diff_otu_markers
});

{% endif %}


/*diff_genus_markers*/
{% if diff_genus_marker_exist %}
var diff_genus_markers=[
 {% for value in diff_genus_marker_data %}
 {{ value }}
	{% endfor %}
 ];

$(function () {
    $('#toolbar10').find('select').change(function () {
        $('#table10').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table10').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, 
	{% for value in diff_genus_marker_jqGrid %}
                {{ value }}
        {% endfor %}

	],
    data: diff_genus_markers
});

{% endif %}


/*diff_taxall_markers*/
{% if diff_taxall_marker_exist %}
 var diff_taxall_markers=[
 {% for value in diff_taxall_marker_data %}
 {{ value }}
	{% endfor %}
 ];

$(function () {
    $('#toolbar11').find('select').change(function () {
        $('#table11').bootstrapTable('refreshOptions', {
            exportTypes:['excel','csv'],
            exportDataType: $(this).val()
        });
    });
})
$('#table11').bootstrapTable({
    exportTypes:['excel','csv'],
    columns: [{
        field: 'state',
        title: 'state',
        checkbox: true,
        
    }, 
	{% for value in diff_taxall_marker_jqGrid %}
		{{ value }}
	{% endfor %}
    ],
    data: diff_taxall_markers
});
{% endif %}
