var test_id;

$(document).ready(function(){
    let maxThreads = navigator.hardwareConcurrency || 4;
    $('#server-poolsize').prop('max', maxThreads);

    $.get( '/demo/request/count', function(data){ $('#request-count').val(data); }, 'text' );
    $.get( '/demo/request/size', function(data){ $('#request-size').val(data); }, 'text' );
    $.get( '/demo/server/delay', function(data){ $('#server-delay').val(data); }, 'text' );
    $.get( '/demo/server/poolsize', function(data){ $('#server-poolsize').val(data); }, 'text' );
    $.get( '/demo/syncmethod', function(data){ $('#sync-method').val(data); }, 'text' );

    // Behaviors.
    $('#request-count').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/request/count/' + $(this).val() }); });
    $('#request-size').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/request/size/' + $(this).val() }); });
    $('#server-delay').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/server/delay/' + $(this).val() }); });
    $('#server-poolsize').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/server/poolsize/' + $(this).val() }); });
    $('#sync-method').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/syncmethod/' + $(this).val() }); });
    $('#run-button').on('click', function(){
        $(this).prop('disabled', true);
        $.ajax({
            method: 'PUT',
            url: '/demo/run-test',
            success: function(data, status){
                console.log('data',data);
                console.log('status',status);
            
                // Polling for test termination.
                const pollingID = setInterval(function(){
                    $.ajax({
                        method: 'GET',
                        url: '/demo/test/status',
                        success: function(data){
                            console.log("Test status:", data);
                            if (data == "DONE") {
                                clearInterval(pollingID);
                                $('#run-button').prop('disabled', false);
                                refreshDashboard();
                            }
                        },
                        error: function(){
                            clearInterval(pollingID);
                            $('#run-button').prop('disabled', false);
                        },
                        dataType: 'text',
                        cache: false
                    });
                }, 500);
            }
        })
    });

    refreshDashboard();
});

function refreshDashboard(){
    console.log('Refreshing dashboard');
    // Get data from server.
    $.get( '/demo/data/networktime', function(data){
        $('#data-networktime').text(parseFloat(data).toFixed(3));
    }, 'text' );

    $.get( '/demo/data/servertime', function(data){
        $('#data-servertime').text(parseFloat(data).toFixed(3));
    }, 'text' );

    $.get( '/demo/data/series', function(data){
        console.log(data);

        // Calculate column width.
        let columnWidth = $('#chart').width() / 60;

        // Adapted from Highcharts stacked columns demo.
        Highcharts.chart('chart', {
            accessibility: { enabled: false }, // Avoids warning in console.
            chart: {
                type: 'column'
            },

            title: {
                text: 'Network and server processing times'
            },

            xAxis: {
                categories: data.id,
                title: {
                    text: 'Request ID'
                }
            },

            yAxis: {
                allowDecimals: true,
                min: 0,
                title: {
                    text: 'Time (ms)'
                }
            },

            tooltip: {
                formatter: function () {
                    return '<b>Request' + (this.x.indexOf('-') > -1 ? 's ' : ' ') + this.x + '</b><br/>' +
                        this.series.name + ': ' + parseFloat(this.y).toFixed(3) + ' ms<br/>' +
                        'Total: ' + parseFloat(this.point.stackTotal).toFixed(3) + ' ms';
                }
            },

            plotOptions: {
                column: {
                    stacking: 'normal'
                },
                series: {
                    pointWidth: columnWidth
                }
            },

            series: [{
                name: 'serverTime',
                data: data.serverTime
            }, {
                name: 'networkTime',
                data: data.networkTime
            }]
        });


    }, 'json' );
};
