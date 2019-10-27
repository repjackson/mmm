if Meteor.isClient
    Template.classroom_cloud.onCreated ->
        @autorun -> Meteor.subscribe('classroom_tags', selected_classroom_tags.array())

    Template.classroom_cloud.helpers
        all_classroom_tags: ->
            classroom_count = Docs.find(model:'classroom').count()
            if 0 < classroom_count < 3 then classroom_tags.find { count: $lt: classroom_count } else classroom_tags.find({},{limit:42})
        selected_classroom_tags: -> selected_classroom_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key

    Template.classroom_cloud.events
        'click .select_classroom_tag': -> selected_classroom_tags.push @name
        'click .unselect_classroom_tag': -> selected_classroom_tags.remove @valueOf()
        'click #clear_classroom_tags': -> selected_classroom_tags.clear()

if Meteor.isServer
    Meteor.publish 'classroom_tags', (selected_classroom_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_classroom_tags.push current_herd

        if selected_classroom_tags.length > 0 then match.tags = $all: selected_classroom_tags
        match.model = 'classroom'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $classroom: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_classroom_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'classroom_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'classroom_facet_docs', (selected_classroom_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_classroom_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_classroom_tags.length > 0 then match.tags = $all: selected_classroom_tags
        match.model = 'classroom'
        Docs.find match, sort:_timestamp:-1
