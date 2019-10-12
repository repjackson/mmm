Template.home.onRendered ->
    # // fix menu when passed
    Meteor.setTimeout ->
        $('.masthead')
            .visibility({
                once: false,
                onBottomPassed: ->
                    $('.fixed.menu').transition('fade in')
                onBottomPassedReverse: ->
                    $('.fixed.menu').transition('fade out')
            })
        $('.ui.sidebar')
            .sidebar('attach events', '.toc.item')
    , 1000
