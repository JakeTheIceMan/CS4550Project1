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

    this.channel.on("update", resp => {
      this.setState(resp.game);
    });
  }

  //n
  restart() {
    this.channel.push("restart")
    .receive("ok", resp => { this.setState(resp.game); });
  }

  choose(r, c) {
    this.channel
    .push("choose", {row: r, column: c})
    .receive("ok", resp => { this.setState(resp.game); });
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

    let restart = (
      <div className="column">
      <button onClick={this.restart.bind(this)}>Restart</button>
      </div>
    );
    let winner = (
      <div className="column">
      <p>The winner is {this.state.winner}!</p>
      </div>
    );
    let turn = (
      <div className="column">
      <h4>It is now {this.state.black_turn ? "black" : "white"}'s turn.</h4>
      </div>
    );

    return (
      <div>
      <div className="row">
      {this.state.winner === "none" ? turn : restart}
      {this.state.winner === "none" ? null : winner}
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
