if Meteor.isClient
    Template.service_cloud.onCreated ->
        @autorun -> Meteor.subscribe('service_tags', selected_service_tags.array())

    Template.service_cloud.helpers
        all_service_tags: ->
            service_count = Docs.find(model:'service').count()
            if 0 < service_count < 3 then Service_tags.find { count: $lt: service_count } else Service_tags.find({},{limit:5})
        # cloud_tag_class: ->
        #     button_class = switch
        #         when @index <= 5 then 'large'
        #         when @index <= 12 then ''
        #         when @index <= 20 then 'small'
        #     return button_class
        selected_service_tags: -> selected_service_tags.array()
        # settings: -> {
        #     position: 'bottom'
        #     limit: 10
        #     rules: [
        #         {
        #             collection: Service_tags
        #             field: 'name'
        #             matchAll: true
        #             template: Template.tag_result
        #         }
        #     ]
        # }


    Template.service_cloud.events
        'click .select_service_tag': -> selected_service_tags.push @name
        'click .unselect_service_tag': -> selected_service_tags.remove @valueOf()
        'click #clear_tags': -> selected_service_tags.clear()

        # 'keyup #search': (e,t)->
        #     e.preventDefault()
        #     val = $('#search').val().toLowerCase().trim()
        #     switch e.which
        #         when 13 #enter
        #             switch val
        #                 when 'clear'
        #                     selected_service_tags.clear()
        #                     $('#search').val ''
        #                 else
        #                     unless val.length is 0
        #                         selected_service_tags.push val.toString()
        #                         $('#search').val ''
        #         when 8
        #             if val.length is 0
        #                 selected_service_tags.pop()
        #
        # 'autocompleteselect #search': (event, template, doc) ->
        #     selected_service_tags.push doc.name
        #     $('#search').val ''


if Meteor.isServer
    Meteor.publish 'service_tags', (selected_service_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_service_tags.push current_herd

        if selected_service_tags.length > 0 then match.tags = $all: selected_service_tags
        match.model = 'service'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_service_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'service_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'service_docs', (selected_service_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_service_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_service_tags.length > 0 then match.tags = $all: selected_service_tags
        match.model = 'service'
        Docs.find match, sort:_timestamp:-1
