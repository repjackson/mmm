if Meteor.isClient
    Template.shop_cloud.onCreated ->
        @autorun -> Meteor.subscribe('shop_tags', selected_shop_tags.array())

    Template.shop_cloud.helpers
        all_shop_tags: ->
            shop_count = Docs.find(model:'shop').count()
            if 0 < shop_count < 3 then Shop_tags.find { count: $lt: shop_count } else Shop_tags.find({},{limit:5})
        # cloud_tag_class: ->
        #     button_class = switch
        #         when @index <= 5 then 'large'
        #         when @index <= 12 then ''
        #         when @index <= 20 then 'small'
        #     return button_class
        selected_shop_tags: -> selected_shop_tags.array()
        # settings: -> {
        #     position: 'bottom'
        #     limit: 10
        #     rules: [
        #         {
        #             collection: Shop_tags
        #             field: 'name'
        #             matchAll: true
        #             template: Template.tag_result
        #         }
        #     ]
        # }


    Template.shop_cloud.events
        'click .select_shop_tag': -> selected_shop_tags.push @name
        'click .unselect_shop_tag': -> selected_shop_tags.remove @valueOf()
        'click #clear_tags': -> selected_shop_tags.clear()

        # 'keyup #search': (e,t)->
        #     e.preventDefault()
        #     val = $('#search').val().toLowerCase().trim()
        #     switch e.which
        #         when 13 #enter
        #             switch val
        #                 when 'clear'
        #                     selected_shop_tags.clear()
        #                     $('#search').val ''
        #                 else
        #                     unless val.length is 0
        #                         selected_shop_tags.push val.toString()
        #                         $('#search').val ''
        #         when 8
        #             if val.length is 0
        #                 selected_shop_tags.pop()
        #
        # 'autocompleteselect #search': (event, template, doc) ->
        #     selected_shop_tags.push doc.name
        #     $('#search').val ''


if Meteor.isServer
    Meteor.publish 'shop_tags', (selected_shop_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_shop_tags.push current_herd

        if selected_shop_tags.length > 0 then match.tags = $all: selected_shop_tags
        match.model = 'shop'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_shop_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'shop_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'shop_docs', (selected_shop_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_shop_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_shop_tags.length > 0 then match.tags = $all: selected_shop_tags
        match.model = 'shop'
        Docs.find match, sort:_timestamp:-1
