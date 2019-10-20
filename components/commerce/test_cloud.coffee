if Meteor.isClient
    Template.test_cloud.onCreated ->
        @autorun -> Meteor.subscribe('test_tags', selected_test_tags.array())
        @autorun -> Meteor.subscribe('test_docs', selected_test_tags.array())
    Template.test_cloud.helpers
        all_test_tags: ->
            test_count = Docs.find(model:'test').count()
            if 0 < test_count < 3 then Test_tags.find { count: $lt: test_count } else Test_tags.find({},{limit:42})
        selected_test_tags: -> selected_test_tags.array()
    Template.test_cloud.events
        'click .select_test_tag': -> selected_test_tags.push @name
        'click .unselect_test_tag': -> selected_test_tags.remove @valueOf()
        'click #clear_tags': -> selected_test_tags.clear()



if Meteor.isServer
    Meteor.publish 'test_tags', (selected_test_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_test_tags.push current_herd

        if selected_test_tags.length > 0 then match.tags = $all: selected_test_tags
        match.model = 'test'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_test_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'test_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'test_docs', (selected_test_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_test_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_test_tags.length > 0 then match.tags = $all: selected_test_tags
        match.model = 'test'
        Docs.find match, sort:_timestamp:-1
