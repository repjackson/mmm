if Meteor.isClient
    Template.service_cloud.onCreated ->
        @autorun -> Meteor.subscribe('service_tags', selected_service_tags.array())
    Template.service_cloud.helpers
        all_service_tags: ->
            service_count = Docs.find(model:'service').count()
            if 0 < service_count < 3 then Service_tags.find { count: $lt: service_count } else Service_tags.find({},{limit:5})
        selected_service_tags: -> selected_service_tags.array()
    Template.service_cloud.events
        'click .select_service_tag': -> selected_service_tags.push @name
        'click .unselect_service_tag': -> selected_service_tags.remove @valueOf()
        'click #clear_tags': -> selected_service_tags.clear()



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
