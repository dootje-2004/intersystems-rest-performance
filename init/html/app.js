var test_id;

$(document).ready(function(){
    let maxThreads = navigator.hardwareConcurrency || 4;
    $('#server-poolsize').prop('max', maxThreads);

    $.get( '/demo/request/count', function(data){ $('#request-count').val(data); }, 'text' );
    $.get( '/demo/request/size', function(data){ $('#request-size').val(data); }, 'text' );
    $.get( '/demo/process/delay', function(data){ $('#server-delay').val(data); }, 'text' );
    $.get( '/demo/process/poolsize', function(data){ $('#server-poolsize').val(data); }, 'text' );
    $.get( '/demo/service/sync', function(data){ $('#service-sync').prop('checked',data=='1'); }, 'text' );
    $.get( '/demo/rest/forward', function(data){ $('#rest-action').val(data); }, 'text' );
    $.get( '/demo/client/sync', function(data){ $('#client-sync').prop('checked',data=='1'); }, 'text' );

    // Behaviors.
    $('#request-count').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/request/count/' + $(this).val() }); });
    $('#request-size').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/request/size/' + $(this).val() }); });
    $('#server-delay').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/process/delay/' + $(this).val() }); });
    $('#server-poolsize').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/process/poolsize/' + $(this).val() }); });
    $('#service-sync').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/service/sync/' + ($(this).prop('checked')?'1':'0') }); });
    $('#rest-action').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/rest/forward/' + $(this).val() }); });
    $('#client-sync').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/client/sync/' + ($(this).prop('checked')?'1':'0') }); });
    $('#run-button').on('click', function(){
        runTest();
        return; // For now.

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
        let columnWidth = $('#chart').width() * 0.8 / data.id.length;

        // Adapted from Highcharts stacked columns demo.
        Highcharts.chart('chart', {
            accessibility: { enabled: false }, // Avoids warning in console.
            chart: { type: 'column' },
            title: { text: 'Network and server processing times' },
            xAxis: {
                categories: data.id,
                title: { text: 'Request ID' } },
            yAxis: {
                allowDecimals: true,
                min: 0,
                title: { text: 'Time (ms)' }
            },
            tooltip: {
                formatter: function(){
                    return '<b>Request' + (this.x.indexOf('-') > -1 ? 's ' : ' ') + this.x + '</b><br/>'
                    + this.series.name + ': ' + parseFloat(this.y).toFixed(3) + ' ms<br/>'
                    + 'Total: ' + parseFloat(this.point.stackTotal).toFixed(3) + ' ms';
                }
            },
            plotOptions: {
                column: { stacking: 'normal' },
                series: { pointWidth: columnWidth }
            },
            series: [
                {
                    name: 'serverTime',
                    data: data.serverTime
                },
                {
                    name: 'networkTime',
                    data: data.networkTime
                }
            ]
        });
    }, 'json' );
};

function runTest(){
    let count = $('#request-count').val();
    let size = $('#request-size').val();
    let payload = "DEMO DEMO ".repeat(Math.round(size / 10));
    for (let i = 0; i < count; i++) sendTestMessage('/demo/', { "id": i, "message": payload });
}

function sendTestMessage(url,body){
    $.ajax({
        async: ! $('#client-sync').prop('checked'),
        contentType: 'application/json',
        data: JSON.stringify(body),
        dataType: 'json',
        headers: { "Accept": "*/*" },
        method: 'POST',
        success: function(data){
            console.log(data);
        },
        url: url
    });
}
