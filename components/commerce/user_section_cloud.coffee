if Meteor.isClient
    Template.user_section_cloud.onCreated ->
        @autorun -> Meteor.subscribe('user_section_tags', selected_user_section_tags.array())
        @autorun -> Meteor.subscribe('user_section_docs', selected_user_section_tags.array())
    Template.user_section_cloud.helpers
        all_user_section_tags: ->
            user_section_count = Docs.find(model:'user_section').count()
            if 0 < user_section_count < 3 then User_section_tags.find { count: $lt: user_section_count } else User_section_tags.find({},{limit:10})
        selected_user_section_tags: -> selected_user_section_tags.array()
    Template.user_section_cloud.events
        'click .select_user_section_tag': -> selected_user_section_tags.push @name
        'click .unselect_user_section_tag': -> selected_user_section_tags.remove @valueOf()
        'click #clear_tags': -> selected_user_section_tags.clear()



if Meteor.isServer
    Meteor.publish 'user_section_tags', (selected_user_section_tags)->
        self = @
        match = {}

        if selected_user_section_tags.length > 0 then match.tags = $all: selected_user_section_tags
        match.model = 'user_section'
        console.log match
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_user_section_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'user_section_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'user_section_docs', (selected_user_section_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_user_section_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_user_section_tags.length > 0 then match.tags = $all: selected_user_section_tags
        match.model = 'user_section'
        Docs.find match, sort:_timestamp:-1
