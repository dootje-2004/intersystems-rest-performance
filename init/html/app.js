var test_id;

$(document).ready(function(){
    let maxThreads = navigator.hardwareConcurrency || 8;
    $('#server-poolsize').prop('max', maxThreads);

    $.get( '/demo/request/count', function(data){ $('#request-count').val(data); }, 'text' );
    $.get( '/demo/request/size', function(data){ $('#request-size').val(data); }, 'text' );
    $.get( '/demo/process/delay', function(data){ $('#server-delay').val(data); }, 'text' );
    $.get( '/demo/process/poolsize', function(data){ $('#server-poolsize').val(data); }, 'text' );
    $.get( '/demo/service/sync', function(data){ 
        $('#service-sync').prop('checked',data=='1'); 
        updateArrows();
    }, 'text' );
    $.get( '/demo/rest/forward', function(data){ 
        $('#api-action').val(data); 
        updateArrows();
    }, 'text' );
    $.get( '/demo/client/sync', function(data){ 
        $('#client-sync').prop('checked',data=='1'); 
        updateArrows();
    }, 'text' );

    // Behaviors.
    $('#request-count').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/request/count/' + $(this).val() }); });
    $('#request-size').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/request/size/' + $(this).val() }); });
    $('#server-delay').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/process/delay/' + $(this).val() }); });
    $('#server-poolsize').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/process/poolsize/' + $(this).val() }); });
    $('#service-sync').on( 'change', function(){ 
        $.ajax({ method: 'PUT', url: '/demo/service/sync/' + ($(this).prop('checked')?'1':'0') }); 
        updateArrows();
    });
    $('#api-action').on( 'change', function(){ $.ajax({ 
        method: 'PUT', url: '/demo/rest/forward/' + $(this).val() }); 
        updateArrows();
    });
    $('#client-sync').on( 'change', function(){ $.ajax({ 
        method: 'PUT', url: '/demo/client/sync/' + ($(this).prop('checked')?'1':'0') }); 
        updateArrows();
    });
    $('#run-button').on('click', function(){
        runTest();
    });
});

function refreshDashboard(){
    console.log('Refreshing dashboard');
    
    // Get data from server.
    $.get( '/demo/data', function(data){
        console.log(data);
        
        // Convert to durations in milliseconds.
        let timeBP = subtractArrays( data.bpRespOut, data.bpReqIn );
        let timeBS = subtractArrays( data.bsRespOut, data.bsReqIn );
        let timeAPI = subtractArrays( data.apiRespOut, data.apiReqIn );
        let timeRoundtrip = subtractArrays( clRespIn, clReqOut );

        let timeNet = subtractArrays( timeRoundtrip, timeAPI );
        timeAPI = subtractArrays( timeAPI, timeBS );
        timeBS = subtractArrays( timeBS, timeBP );

        // Convert seconds to milliseconds.
        timeBP = multiplyArray( timeBP, 1000 );
        timeBS = multiplyArray( timeBS, 1000 );
        timeAPI = multiplyArray( timeAPI, 1000 );
        timeNet = multiplyArray( timeNet, 1000 );
        timeRoundtrip = multiplyArray( timeRoundtrip, 1000 );

        $('#data-roundtriptime').text( avg(timeRoundtrip).toFixed(3) );
        $('#data-networktime').text( avg(timeNet).toFixed(3) );
        $('#data-apitime').text( avg(timeAPI).toFixed(3) );
        $('#data-bstime').text( avg(timeBS).toFixed(3) );
        $('#data-bptime').text( avg(timeBP).toFixed(3) );
        let totalTime = clRespIn[ parseInt( $('#request-count').val() ) - 1] - clReqOut[0];
        $('#data-testtime-total').text( totalTime.toFixed(3) );
        $('#data-transfer-rate').text( (clReqOut.length / totalTime).toFixed(3) );
        
        // Calculate column width.
        let columnWidth = $('#chart').width() * 0.8 / data.id.length;

        // Adapted from Highcharts stacked columns demo.
        Highcharts.chart('chart', {
            accessibility: { enabled: false }, // Avoids warning in console.
            chart: { type: 'column' },
            title: { text: 'Timing' },
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
                    name: 'BP',
                    data: timeBP
                },
                {
                    name: 'BS',
                    data: timeBS
                },
                {
                    name: 'API',
                    data: timeAPI
                },
                {
                    name: 'network',
                    data: timeNet
                }
            ]
        });
    }, 'json' );
};

var clReqOut, clReqIn;

function runTest(){
    $('#run-button').prop('disabled', true);
    let count = $('#request-count').val();
    let size = $('#request-size').val();
    let payload = "DEMO DEMO ".repeat(Math.round(size / 10));
    clReqOut = [];
    clRespIn = [];
    responseCount = 0;
    // Signal to the server that we are initiating a new test run.
    $.ajax({
        url: '/demo/data',
        async: false,
        method: 'DELETE',
        success: function(){
            for (let i = 0; i < count; i++) sendTestMessage('/demo/', { "id": i, "message": payload });
        }
    });
}

function sendTestMessage(url,body,callback){
    clReqOut[ body.id ] = Date.now() / 1000;
    $.ajax({
        url: url,
        async: ! $('#client-sync').prop('checked'),
        contentType: 'application/json',
        data: JSON.stringify(body),
        dataType: 'json',
        headers: { "Accept": "*/*" },
        method: 'POST',
        success: function(data){
            responseCount++;
            clRespIn[data.id] = Date.now() / 1000 ;
            console.log(data);
            if ( responseCount == $('#request-count').val() ) {
                refreshDashboard();
                $('#run-button').prop('disabled', false);
            }
        }
    });
}

function subtractArrays(a,b) {
    return a.map(function(item, index) { return item - b[index]; });
}

function multiplyArray(a,m) {
    return a.map(function(item, index) { return item * m; });
}

function avg(arr) {
    return arr.reduce( (a,b)=> a + b, 0) / arr.length || 0;
}

function updateArrows() {
    
    if ( $('#api-action').val() == 'SYNC' ) {
        $('#arrow-api-bs').css('visibility','visible');
        $('#arrow-bs-api').css('visibility','visible');
        $('#arrow-api-db').css('visibility','hidden');
        $('#arrow-bp-db').css('visibility','visible');
        $('#arrow-bs-bp').css('visibility','visible');
        if ( $('#service-sync').prop('checked') ) {
            $('#arrow-bp-bs').css('visibility','visible');
        } else {
            $('#arrow-bp-bs').css('visibility','hidden');
        }
    } else if ( $('#api-action').val() == 'ASYNC' ) {
        $('#arrow-api-bs').css('visibility','visible');
        $('#arrow-bs-api').css('visibility','hidden');
        $('#arrow-api-db').css('visibility','hidden');
        $('#arrow-bp-db').css('visibility','visible');
        $('#arrow-bs-bp').css('visibility','visible');
        if ( $('#service-sync').prop('checked') ) {
            $('#arrow-bp-bs').css('visibility','visible');
        } else {
            $('#arrow-bp-bs').css('visibility','hidden');
        }
    } else {
        $('#arrow-api-bs').css('visibility','hidden');
        $('#arrow-bs-api').css('visibility','hidden');
        $('#arrow-api-db').css('visibility','visible');
        $('#arrow-bp-db').css('visibility','hidden');
        $('#arrow-bs-bp').css('visibility','hidden');
        $('#arrow-bp-bs').css('visibility','hidden');
    }
    
    if ( $('#client-sync').prop('checked')) {
        $('#arrow-api-client').css('opacity','1');
    } else {
        $('#arrow-api-client').css('opacity','.4');
    }
}