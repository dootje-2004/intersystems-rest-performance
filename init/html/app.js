var test_id;

$(document).ready(function(){
    let maxThreads = navigator.hardwareConcurrency || 4;
    $('#server-poolsize').prop('max', maxThreads);

    $.get( '/demo/settings', function(data){
        $('#request-count').val(data.callcount);
        $('#request-size').val(data.payloadsize); 
        if (data.payloadsize > 3641144 ) {
            $('#request-type').prop('disabled',true);
        }
        $('#request-type').prop('checked', data.payloaddatatype=='string');
        $('#server-delay').val(data.bpdelay);
        $('#server-poolsize').val(data.bppoolsize);
        $('#service-sync').prop('checked', data.bssync=='1'); 
        $('#api-action').val(data.restforwarding); 
        $('#client-sync').prop('checked',data.clientsync=='1'); 
        updateArrows();
    }, 'json' );

    // Attach behaviors.
    $('#request-count').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/setting/callcount/' + $(this).val() }); });
    $('#request-size').on( 'input', function(){ 
        $.ajax({ method: 'PUT', url: '/demo/setting/payloadsize/' + $(this).val() }); 
        if ($(this).val() > 3641144) {
            $('#request-type').prop('checked', false).prop('disabled',true);
        } else {
            $('#request-type').prop('disabled', false);
        }
    });
    $('#request-type').on( 'change', function(){ 
        $.ajax({ method: 'PUT', url: '/demo/setting/payloaddatatype/' + ($(this).prop('checked')?'string':'stream') }); 
    });
    $('#server-delay').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/setting/bpdelay/' + $(this).val() }); });
    $('#server-poolsize').on( 'change', function(){ $.ajax({ method: 'PUT', url: '/demo/setting/bppoolsize/' + $(this).val() }); });
    $('#service-sync').on( 'change', function(){ 
        $.ajax({ method: 'PUT', url: '/demo/setting/bssync/' + ($(this).prop('checked')?'1':'0') }); 
        updateArrows();
    });
    $('#api-action').on( 'change', function(){ $.ajax({ 
        method: 'PUT', url: '/demo/setting/restforwarding/' + $(this).val() }); 
        updateArrows();
    });
    $('#client-sync').on( 'change', function(){ $.ajax({ 
        method: 'PUT', url: '/demo/setting/clientsync/' + ($(this).prop('checked')?'1':'0') }); 
        updateArrows();
    });
    $('#run-button').on('click', function(){
        runTest();
    });
    $('#message-button').on('click', function(){
        window.open( '/csp/demo/EnsPortal.MessageViewer.zen', '_blank' ).focus();
    });
    $('#production-button').on('click', function(){
        window.open( '/csp/demo/EnsPortal.ProductionConfig.zen?PRODUCTION=Demo.Production', '_blank' ).focus();
    });
});

function refreshDashboard(){    
    // Get data from server.
    $.get( '/demo/data', function(data){
        
        // Convert to durations in milliseconds.
        let timeBP = subtractArrays( data.bpRespOut.y, data.bpReqIn.y );
        let timeBS = subtractArrays( data.bsRespOut.y, data.bsReqIn.y );
        let timeAPI = subtractArrays( data.apiRespOut.y, data.apiReqIn.y );
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
        let columnWidth = $('#chart').width() * 0.8 / data.id.y.length;

        // Adapted from Highcharts stacked columns demo.
        Highcharts.chart('chart', {
            accessibility: { enabled: false }, // Avoids warning in console.
            chart: { type: 'column' },
            title: { text: 'Timing' },
            xAxis: {
                categories: data.id.y,
                title: { text: 'Request ID' } },
            yAxis: {
                allowDecimals: true,
                min: 0,
                title: { text: 'Time (ms)' }
            },
            tooltip: {
                formatter: function(){
                    let pid = 0;
                    if (this.series.name != 'network') {
                        pid = data[this.series.name.toLowerCase() + 'ReqIn'].pid[this.x];
                    }
                    return '<b>Request' + (this.x.indexOf('-') > -1 ? 's ' : ' ') + this.x + '</b><br/>'
                    + this.series.name + ': ' + parseFloat(this.y).toFixed(3) + ' ms<br/>'
                    + ( pid ? 'PID: ' + pid + '<br/>' : '' )
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
            let url = '/demo/call/';
            if ( $('#api-action').val() == 'STORE' ){
                url += 'store/';
            } else {
                url += 'forward/';
                url += $('#service-sync').prop('checked') ? 'sync/' : 'async/';
            }
            url += $('#request-type').prop('checked') ? 'string' : 'stream';
            for (let i = 0; i < count; i++) sendTestMessage(url, { "id": i, "message": payload });
        }
    });
}

function sendTestMessage(url,body,callback){
    clReqOut[ body.id ] = window.performance.now() / 1000.0;
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
            clRespIn[data.id] = window.performance.now() / 1000 ;
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