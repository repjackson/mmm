if Meteor.isClient
    Template.question_cloud.onCreated ->
        @autorun -> Meteor.subscribe('question_tags', selected_question_tags.array())
        @autorun -> Meteor.subscribe('question_docs', selected_question_tags.array())
    Template.question_cloud.helpers
        all_question_tags: ->
            question_count = Docs.find(model:'question').count()
            if 0 < question_count < 3 then Question_tags.find { count: $lt: question_count } else Question_tags.find({},{limit:42})
        selected_question_tags: -> selected_question_tags.array()
    Template.question_cloud.events
        'click .select_question_tag': -> selected_question_tags.push @name
        'click .unselect_question_tag': -> selected_question_tags.remove @valueOf()
        'click #clear_tags': -> selected_question_tags.clear()



if Meteor.isServer
    Meteor.publish 'question_tags', (selected_question_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_question_tags.push current_herd

        if selected_question_tags.length > 0 then match.tags = $all: selected_question_tags
        match.model = 'question'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_question_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'question_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'question_docs', (selected_question_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_question_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_question_tags.length > 0 then match.tags = $all: selected_question_tags
        match.model = 'question'
        Docs.find match, sort:_timestamp:-1
