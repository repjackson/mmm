if Meteor.isClient
    Template.group_cloud.onCreated ->
        @autorun -> Meteor.subscribe('group_tags', selected_group_tags.array())

    Template.group_cloud.helpers
        all_group_tags: ->
            group_count = Docs.find(model:'group').count()
            if 0 < group_count < 3 then Group_tags.find { count: $lt: group_count } else Group_tags.find({},{limit:42})
        selected_group_tags: -> selected_group_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key

    Template.group_cloud.events
        'click .select_group_tag': -> selected_group_tags.push @name
        'click .unselect_group_tag': -> selected_group_tags.remove @valueOf()
        'click #clear_group_tags': -> selected_group_tags.clear()

if Meteor.isServer
    Meteor.publish 'group_tags', (selected_group_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_group_tags.push current_herd

        if selected_group_tags.length > 0 then match.tags = $all: selected_group_tags
        match.model = 'group'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_group_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'group_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'group_facet_docs', (selected_group_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_group_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_group_tags.length > 0 then match.tags = $all: selected_group_tags
        match.model = 'group'
        Docs.find match, sort:_timestamp:-1
