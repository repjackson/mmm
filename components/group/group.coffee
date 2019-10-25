if Meteor.isClient
    Router.route '/groups', ->
        @render 'groups'
    Router.route '/my_groups', ->
        @layout 'leader_layout'
        @render 'my_groups'

    Router.route '/group/:doc_id/', (->
        @layout 'group_view_layout'
        @render 'group_members'
        ), name:'group_view'
    Router.route '/group/:doc_id/dashboard', (->
        @layout 'group_view_layout'
        @render 'group_dashboard'
        ), name:'group_dashboard'
    Router.route '/group/:doc_id/reports', (->
        @layout 'group_view_layout'
        @render 'group_reports'
        ), name:'group_reports'
    Router.route '/group/:doc_id/stats', (->
        @layout 'group_view_layout'
        @render 'group_stats'
        ), name:'group_stats'
    Router.route '/group/:doc_id/lunch', (->
        @layout 'mlayout'
        @render 'group_lunch'
        ), name:'group_lunch'
    Router.route '/group/:doc_id/debits', (->
        @layout 'group_view_layout'
        @render 'group_debits'
        ), name:'group_debits'
    Router.route '/group/:doc_id/credits', (->
        @layout 'group_view_layout'
        @render 'group_credits'
        ), name:'group_credits'
    Router.route '/group/:doc_id/members', (->
        @layout 'group_view_layout'
        @render 'group_members'
        ), name:'group_members'
    Router.route '/group/:doc_id/feed', (->
        @layout 'group_view_layout'
        @render 'group_feed'
        ), name:'group_feed'
    Router.route '/group/:doc_id/loans', (->
        @layout 'group_view_layout'
        @render 'group_loans'
        ), name:'group_loans'


    Template.group_card.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group_stats'
    Template.groups.helpers




    # Template.group_dashboard.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'model_docs', 'credit_type'
    # Template.group_dashboard.onRendered ->
    #     Meteor.setTimeout ->
    #         $('#date_calendar')
    #             .calendar({
    #                 type: 'date'
    #             })
    #     , 700
    # Template.group_dashboard.helpers
    #     individual_credit_types: ->
    #         Docs.find
    #             model:'credit_type'
    #             # weekly:$ne:true
    #             group_id: Router.current().params.doc_id

    Template.group_members.onCreated ->
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_docs', 'credit_type', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_docs', 'debit_type', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_docs', 'group_event', Router.current().params.doc_id
    Template.group_members.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion(
                selector:
                    trigger: '.title .header'
            )
        , 1000

    Template.group_members.helpers
        # bulk_action_class: ->
        #     console.log @
        weekly_automatic_debits: ->
            Docs.find
                model:'debit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'weekly'
        weekly_automatic_credits: ->
            Docs.find
                model:'credit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'weekly'
        daily_automatic_debits: ->
            Docs.find
                model:'debit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'daily'
        daily_automatic_credits: ->
            Docs.find
                model:'credit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'daily'
        weekly_manual_debits: ->
            Docs.find
                model:'debit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'weekly'
        weekly_manual_credits: ->
            Docs.find
                model:'credit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'weekly'
        daily_manual_debits: ->
            Docs.find
                model:'debit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'daily'
        daily_manual_credits: ->
            Docs.find
                model:'credit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'daily'
        daily_manual_group_debits: ->
            Docs.find
                model:'debit_type'
                group_id: Router.current().params.doc_id
                dispersion_type:'manual'
                scope:'group'
                manual_period:'daily'
        daily_manual_group_credits: ->
            Docs.find
                model:'credit_type'
                group_id: Router.current().params.doc_id
                scope:'group'
                dispersion_type:'manual'
                manual_period:'daily'
        group_members: ->
            group = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: group.member_ids
        individual_credit_types: ->
            Docs.find
                model:'credit_type'
                dispersion_type: 'manual'
                scope: 'individual'
                group_id: Router.current().params.doc_id
        individual_debit_types: ->
            Docs.find
                model:'debit_type'
                dispersion_type: 'manual'
                scope: 'individual'
                group_id: Router.current().params.doc_id
        group_debit_types: ->
            Docs.find
                model:'debit_type'
                scope: 'group'
                group_id: Router.current().params.doc_id
        member_events: ->
            Docs.find
                model:'group_event'
                user_id: @_id

    Template.group_members.events
        'click .debit_group': ->
            group = Docs.findOne Router.current().params.doc_id
            $('.title').transition('shake', 500)
            for member_id in group.member_ids
                member = Meteor.users.findOne member_id
                Meteor.users.update member._id,
                    $inc:credit:-@amount
                Docs.insert
                    model:'group_event'
                    event_type:'debit'
                    amount: @amount
                    event_type_id: @_id
                    text:"was debited #{@amount} for #{@title}"
                    user_id: member._id
                    group_id: Router.current().params.doc_id
                $('body').toast({
                    message: "#{member.first_name} #{member.last_name} was debited #{@amount} for #{@title}"
                    class:'error'
                    showProgress: 'bottom'
                })
            # Docs.update Router.current().params.doc_id,
            #     $inc:credit:-@amount
            Docs.insert
                model:'group_event'
                event_type:'debit'
                amount: @amount
                event_type_id: @_id
                text:"group was debited #{@amount} for #{@title}"
                group_id: Router.current().params.doc_id
            $('body').toast({
                message: "group was debited #{@amount} for #{@title}"
                class:'error'
                showProgress: 'bottom'
            })

        'click .credit_group': ->
            group = Docs.findOne Router.current().params.doc_id
            $('.title').transition('bounce', 500)
            for member_id in group.member_ids
                member = Meteor.users.findOne member_id
                $('body').toast({
                    message: "#{member.first_name} #{member.last_name} was credited #{@amount} for #{@title}"
                    class:'success'
                    showProgress: 'bottom'
                })
                Meteor.users.update member._id,
                    $inc:credit:@amount
                Docs.insert
                    model:'group_event'
                    event_type:'credit'
                    amount: @amount
                    text:"was credited #{@amount} for #{@title}"
                    user_id: member._id
                    group_id: Router.current().params.doc_id
            Docs.insert
                model:'group_event'
                event_type:'credit'
                amount: @amount
                event_type_id: @_id
                text:"group was credited #{@amount} for #{@title}"
                group_id: Router.current().params.doc_id
            $('body').toast({
                message: "group was credited #{@amount} for #{@title}"
                class:'success'
                showProgress: 'bottom'
            })

        'click .add_bonus': (e,t)->
            # alert 'hi'
            # console.log @
            group = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.title').transition('bounce', 500)
            # console.log @
            if Meteor.user()
                $('body').toast({
                    message: "#{group.bonus_amount}c bonus given to #{@first_name} #{@last_name}"
                    class:'success'
                    showProgress: 'bottom'
                })

                Meteor.users.update @_id,
                    $inc:credit:group.bonus_amount
                Docs.insert
                    model:'group_event'
                    event_type:'credit'
                    amount: group.bonus_amount
                    text:"was credited #{group.bonus_amount}"
                    user_id: @_id
                    group_id: Router.current().params.doc_id
            else
                $('body').toast({
                    message: 'need to be logged in to give bonus'
                    class:'success'
                    showProgress: 'bottom'
                })

        'click .add_fine': (e,t)->
            group = Docs.findOne Router.current().params.doc_id

            $(e.currentTarget).closest('.title').transition('shake', 500)
            if Meteor.user()
                $('body').toast({
                    message: "#{group.fines_amount}c fine given to #{@first_name} #{@last_name}"
                    class:'error'
                    showProgress: 'bottom'
                })

                Meteor.users.update @_id,
                    $inc:credit:-group.fines_amount
                Docs.insert
                    model:'group_event'
                    event_type:'debit'
                    amount: group.fines_amount
                    text:"was fined #{group.fines_amount}"
                    user_id: @_id
                    group_id: Router.current().params.doc_id
            else
                $('body').toast({
                    message: 'need to be logged in to give fine'
                    class:'error'
                    showProgress: 'bottom'
                })

        'change .date_select': ->
            console.log $('.date_select').val()




    Template.group_lunch.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_docs', 'group_event', Router.current().params.doc_id
    Template.group_members.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000
    Template.group_lunch.events
        'click .back_to_group': ->
            Router.go "/group/#{Router.current().params.doc_id}/"
        'click .choose_home': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'group_event'
                    event_type:'debit'
                    amount: -3
                    debit_type: 'lunch'
                    date:moment().format("MM-DD-YYYY")
                    text:"was debited 3 for a home lunch"
                    user_id: @_id
                    group_id: Router.current().params.doc_id
            , 1000

        'click .choose_cafeteria': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'group_event'
                    event_type:'debit'
                    amount: -5
                    date:moment().format("MM-DD-YYYY")
                    debit_type: 'lunch'
                    text:"was debited 5 for a cafeteria lunch"
                    user_id: @_id
                    group_id: Router.current().params.doc_id
            , 1000

    Template.group_lunch.helpers
        group_members: ->
            group = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: group.member_ids

        lunch_chosen: ->
            today = moment().format("MM-DD-YYYY")
            chosen_lunch = Docs.findOne
                debit_type:'lunch'
                date:today
                user_id: @_id
            console.log chosen_lunch
            chosen_lunch
        group_debit_types: ->
            Docs.find
                model:'debit_type'
                # weekly:$ne:true
                group_id: Router.current().params.doc_id





    Template.individual_credit_button.events
        'click .credit_member': ->
            member = Template.parentData()
            # console.log @
            Meteor.users.update member._id,
                $inc:credit:@amount
            Docs.insert
                model:'group_event'
                event_type:'credit'
                amount: @amount
                event_type_id: @_id
                text:"was credited #{@amount} for #{@title}"
                user_id: member._id
                group_id: Router.current().params.doc_id
            $('body').toast({
                message: "#{member.first_name} #{member.last_name} was credited #{@amount} for #{@title}"
                class:'success'
                showProgress: 'bottom'
            })

    Template.individual_debit_button.events
        'click .debit_member': ->
            member = Template.parentData()
            # console.log @
            Meteor.users.update member._id,
                $inc:credit:-@amount
            Docs.insert
                model:'group_event'
                event_type:'debit'
                amount: @amount
                event_type_id: @_id
                text:"was debited #{@amount} for #{@title}"
                user_id: member._id
                group_id: Router.current().params.doc_id
            $('body').toast({
                message: "#{member.first_name} #{member.last_name} was debited #{@amount} for #{@title}"
                class:'error'
                showProgress: 'bottom'
            })




    Template.group_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id
    # Template.group_reports.onRendered ->
    #     Meteor.setTimeout ->
    #         $('#date_calendar')
    #             .calendar({
    #                 type: 'date'
    #             })
    #     , 700
    Template.group_reports.helpers
        group_members: ->
            group = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: group.member_ids
    Template.group_reports.events
        'change .date_select': ->
            console.log $('.date_select').val()







    Template.group_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'feature'
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id

    Template.group_view_layout.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        # Meteor.setTimeout ->
        #     $('.tabular.menu .item').tab()
        # , 1000

    Template.group_view_layout.helpers
        # features: ->
        #     Docs.find
        #         model:'feature'
        # feature_view_template: ->
        #     "#{@title}_view_template"
        #
        # selected_features: ->
        #     group = Docs.findOne Router.current().params.doc_id
        #     Docs.find(
        #         _id: $in: group.feature_ids
        #         model:'feature'
        #     ).fetch()




    Template.group_feed.onCreated ->
        @autorun => Meteor.subscribe 'group_docs', 'group_event', Router.current().params.doc_id
    Template.group_feed.helpers
        group_events: ->
            Docs.find {
                model:'group_event'
                group_id:Router.current().params.doc_id
            }, sort: _timestamp:-1

    Template.group_feed.events
        'click .remove_all_events': ->
            if confirm 'remove all events?'
                events = Docs.find({
                    model:'group_event'
                    group_id:Router.current().params.doc_id
                }).fetch()
                for event in events
                    Docs.remove event._id



        'click .remove': (e,t)->
            if confirm  "undo #{@event_type}?"
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 500
                if @event_type is 'credit'
                    Meteor.users.update @user_id,
                        $inc:credit:-@amount
                else if @event_type is 'debit'
                    Meteor.users.update @user_id,
                        $inc:credit:@amount







    Template.group_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group_stats'
    Template.group_stats.helpers
        gsd: ->
            Docs.findOne
                model:'group_stats'
                group_id:Router.current().params.doc_id
    Template.group_stats.events
        'click .refresh_group_stats': ->
            Meteor.call 'refresh_group_stats', @_id




if Meteor.isServer
    Meteor.publish 'group_members', (group_id)->
        group = Docs.findOne group_id
        Meteor.users.find
            _id: $in: group.member_ids

    Meteor.publish 'group_docs', (model, group_id)->
        Docs.find
            model:model
            group_id:group_id


    Meteor.methods
        refresh_group_stats: (group_id)->
            group = Docs.findOne group_id
            # console.log group
            group_stats_doc = Docs.findOne
                model:'group_stats'
                group_id: group_id

            unless group_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'group_stats'
                    group_id: group_id
                group_stats_doc = Docs.findOne new_stats_doc_id

            member_count = group.member_ids.length

            debits = Docs.find({
                model:'group_event'
                event_type:'debit'
                group_id:group_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'group_event'
                event_type:'credit'
                group_id:group_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            group_balance = total_credit_amount-total_debit_amount

            average_credit_per_member = total_credit_amount/member_count
            average_debit_per_member = total_debit_amount/member_count


            Docs.update group_stats_doc._id,
                $set:
                    member_count: member_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    debit_count: debit_count
                    credit_count: credit_count
                    group_balance: group_balance
                    average_credit_per_member: average_credit_per_member.toFixed(2)
                    average_debit_per_member: average_debit_per_member.toFixed(2)

            # .ui.small.header total earnings
            # .ui.small.header group ranking #reservations
            # .ui.small.header group ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg group time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
