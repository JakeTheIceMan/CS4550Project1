import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Starter channel={channel}/>, root);
}

class Starter extends React.Component {
  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.state = {
      black_turn: true,
      board: []
    };

    this.channel
    .join()
    .receive("ok", resp => {
      console.log("Joined successfully!", resp);
      this.setState(resp.game);
    })
    .receive("error", resp => {
      console.log("Unable to join", resp);
    });
  }

  //n
  restart() {
    this.channel.push("restart")
    .receive("ok", resp => { this.setState(resp.game); });
  }

  choose(r, c) {
    if (this.state.black_turn) {
      this.channel
      .push("choose", {row: r, column: c, player: "black"})
      .receive("ok", resp => { this.setState(resp.game); });
    } else {
      this.channel
      .push("choose", {row: r, column: c, player: "white"})
      .receive("ok", resp => { this.setState(resp.game); });
    }
  }

  //r
  render() {
    let board = _.map(this.state.board, (row, rowIndex) => {
      return <ShowRow
      key={rowIndex}
      rowIndex={rowIndex}
      root={this}
      choose={this.choose.bind(this)}
      row={row} />;
    });

    return (
      <div>
      <div className="row">
      <div className="column">
      <button onClick={this.restart.bind(this)}>Restart</button>
      </div>
      </div>
      {board}
      </div>
    );
  }
}

function ShowRow(props) {
  let renderedRow = _.map(props.row, (col, colIndex) => {
    return (
      <div className="column" key={colIndex}>
      <div className={col.color} onClick={
        () => props.choose(props.rowIndex, colIndex)
      }/>
      </div>
    )
  });

  return <div className="row">{renderedRow}</div>;
}
