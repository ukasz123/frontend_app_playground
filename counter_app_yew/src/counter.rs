use yew::prelude::*;

pub enum CounterMsg {
    AddOne,
    SubstractOne,
}

/// The model (state) of "Counter" component
pub struct CounterModel {
    value: i64,
}

impl Component for CounterModel {
    type Message = CounterMsg;
    type Properties = ();

    fn create(_ctx: &Context<Self>) -> Self {
        Self { value: 0 }
    }

    fn update(&mut self, _ctx: &Context<Self>, msg: Self::Message) -> bool {
        match msg {
            CounterMsg::AddOne => {
                self.value += 1;
                // the value has changed so we need to
                // re-render for it to appear on the page
                true
            }
            CounterMsg::SubstractOne => {
                self.value -= 1;
                true
            }
        }
    }

    fn view(&self, ctx: &Context<Self>) -> Html {
        // This gives us a component's "`Scope`" which allows us to send messages, etc to the component.
        let link = ctx.link();
        html! {
            <div class={classes!("columns")}>
                <div class={classes!("column")}>
                    <button class={classes!("button", "is-warning")} onclick={link.callback(|_| CounterMsg::SubstractOne)}>{ "Decrease" }</button>
                </div>
                <div class={classes!("column")}>
                    <span>{ self.value }</span>
                </div>
                <div class={classes!("column")}>
                    <button class={classes!("button", "is-success")} onclick={link.callback(|_| CounterMsg::AddOne)}>{ "Increase" }</button>
                </div>
            </div>
        }
    }
}
